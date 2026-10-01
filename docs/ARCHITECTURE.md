# CamlQt6 Architecture & Technical Design

`CamlQt6` provides safe, high-performance, and idiomatic OCaml bindings for the **Qt 6** application framework. This document details the technical design decisions, memory model, concurrency guarantees, and internal FFI plumbing.

---

## 1. High-Level Architecture

`CamlQt6` is architected in distinct layers:

```
┌────────────────────────────────────────────────────────┐
│             Declarative / Reactive DSL (`Dsl`)         │
│     Reactive Signals (`State`), Trees (`vbox`, etc.)   │
├────────────────────────────────────────────────────────┤
│          High-Level OCaml API (`Widgets`, `Gui`)       │
│  Phantom Subtyping, Canvas Trampolines, TableModel     │
├────────────────────────────────────────────────────────┤
│             Safe C++ FFI Bridge (`CamlQt6_stubs`)         │
│  CamlDomainLockGuard, QPointer Tracking, Root Cleanup  │
├────────────────────────────────────────────────────────┤
│                     Native Qt 6 Core & GUI             │
│            QtCore, QtGui, QtWidgets (C++20)            │
└────────────────────────────────────────────────────────┘
```

---

## 2. Memory Management & Object Lifetime

Qt uses an ownership tree where `QObject` parent-child relationships dictate destruction: when a parent `QObject` is deleted, it automatically deletes all of its children. In an OCaml environment with a generational tracing garbage collector, naive FFI bindings easily lead to double-free or use-after-free bugs.

### 2.1 Guarded Pointers (`QPointer<QObject>`)

Instead of storing raw C++ pointers (`QWidget*`) directly in OCaml `Custom_tag` blocks, `CamlQt6` stores a heap-allocated `QPointer<QObject>`:

```cpp
struct QObjectBox {
    QPointer<QObject> ptr;
    bool owned_by_ocaml;
};
```

1. **Safety:** When Qt deletes an object (either explicitly or via cascade deletion of its parent window), Qt automatically zeroes all `QPointer` instances referencing it.
2. **Dynamic Invalidation:** Before any method invocation, `get_qobject<T>(val)` checks if the `QPointer` is null. If so, it raises an OCaml exception rather than causing a segmentation fault.
3. **No Double-Free:** When the OCaml GC collects the custom block, the finalizer checks `owned_by_ocaml` and `ptr.isNull()`. If the object is still alive and owned by OCaml (i.e. not yet reparented to a Qt parent), `delete ptr.data()` is called. If the object has been reparented, the C++ object lifetime is transferred to Qt's parent hierarchy.

### 2.2 Callback Root Management (`connect_root_cleanup`)

When an OCaml closure is connected to a Qt signal (e.g., `QPushButton::clicked` or `QTimer::timeout`), the closure value must not be collected by the OCaml GC while the Qt object is alive.

1. Each callback allocates a persistent global root via `caml_register_global_root(root)`.
2. To prevent memory leaks, `connect_root_cleanup(sender, root)` attaches a listener to the sender's `QObject::destroyed` signal:
   ```cpp
   QObject::connect(sender, &QObject::destroyed, [root]() {
       caml_remove_global_root(root);
       delete root;
   });
   ```
3. When the Qt object is destroyed, its associated callback roots are unregistered and freed automatically.

---

## 3. OCaml 5 Multicore & Domain Lock Safety

OCaml 5 enforces a domain runtime lock. Calling OCaml runtime functions or closures from a foreign thread without acquiring the domain lock results in immediate crashes or corrupt state. Furthermore, nested signal invocations within the same thread can lead to deadlocks if the lock is acquired recursively.

### 3.1 Re-entrant Domain Lock Guard (`CamlDomainLockGuard`)

`CamlQt6` implements a thread-local re-entrant lock guard:

```cpp
static thread_local int thread_domain_lock_depth = 0;

class CamlDomainLockGuard {
    bool acquired = false;
public:
    CamlDomainLockGuard() {
        if (thread_domain_lock_depth == 0) {
            caml_acquire_runtime_system();
            acquired = true;
        }
        thread_domain_lock_depth++;
    }
    ~CamlDomainLockGuard() {
        thread_domain_lock_depth--;
        if (acquired && thread_domain_lock_depth == 0) {
            caml_release_runtime_system();
        }
    }
};
```

Whenever Qt invokes a signal handler or virtual method trampoline that dispatches to OCaml:
- If the current thread already holds the domain lock, depth is incremented without re-locking.
- If entering from Qt's native event loop, `caml_acquire_runtime_system()` is called safely.

### 3.2 Non-Blocking Modal Dialogs

For blocking modal dialogs (`QColorDialog::getColor`, `QFontDialog::getFont`, `QInputDialog::getText`, `QFileDialog`), the OCaml runtime system is released before entering Qt's modal nested event loop, allowing other OCaml domains and background threads to continue executing:

```cpp
thread_domain_lock_depth--;
caml_release_runtime_system();
QColor res = QColorDialog::getColor(initial, parent, title);
caml_acquire_runtime_system();
thread_domain_lock_depth++;
```

---

## 4. Subtyping via Phantom Types

Qt widgets form an inheritance hierarchy:
```
QObject -> QWidget -> QPushButton
                   -> QLineEdit
                   -> QTableView
                   -> QMainWindow
```

Instead of requiring explicit upcasting or sacrificing type safety, `CamlQt6` encodes the hierarchy using **phantom polymorphic variants**:

```ocaml
type (+'a) t

type qobject = [ `QObject ]
type qwidget = [ qobject | `QWidget ]
type qpush_button = [ qwidget | `QPushButton ]
```

Functions that accept any widget use open variants (`[> `QWidget ] t`):
```ocaml
val add_widget : [> `QBoxLayout ] Core.t -> ?stretch:int -> [> `QWidget ] Core.t -> unit
```

This guarantees:
- Any `QPushButton` (`qpush_button Core.t`) can be passed directly to `Layout.add_widget` without casting.
- Passing a non-widget (e.g. `QTimer` of type `qtimer Core.t`) is rejected at compile time.
- Zero runtime overhead: all types erase to the same underlying pointer representation.
- [`Widget.as_widget`](file:///home/yotam/source/ocaml/CamlQt6/src/widgets.ml#L138) provides a statically verified coercion for heterogeneous collections.

---

## 5. Event Trampolines (`OCamlCanvas`)

For custom rendering and interactive 2D graphics, `CamlQt6` implements a C++ virtual method trampoline subclass, `OCamlCanvas : public QWidget`:

```cpp
class OCamlCanvas : public QWidget {
protected:
    void paintEvent(QPaintEvent* event) override;
    void mousePressEvent(QMouseEvent* event) override;
    void mouseReleaseEvent(QMouseEvent* event) override;
    void mouseMoveEvent(QMouseEvent* event) override;
    void keyPressEvent(QKeyEvent* event) override;
    void resizeEvent(QResizeEvent* event) override;
};
```

1. **Safe Painter Scope:** Inside `paintEvent`, a `QPainter` is allocated on the stack and bound to the widget. A temporary OCaml handle wrapping `QPainter*` is passed to the user's callback. When the callback finishes, the OCaml handle is explicitly invalidated, preventing use of dangling painter pointers.
2. **Polymorphic Casts (`dynamic_cast`):** `CamlQt6` uses `dynamic_cast<T*>` on `get_qobject` to support custom virtual subclasses without requiring `Q_OBJECT` macro code generation (`moc`).

---

## 6. Zero-Copy Functional Model/View Architecture

Qt's `QTableView`, `QTreeView`, and `QListView` expect a `QAbstractItemModel`. Standard bindings often serialize data into C++ `QStandardItemModel` structures, duplicating memory.

`CamlQt6` implements `OCamlTableModel : public QAbstractTableModel`:
- Directly delegates `rowCount()`, `columnCount()`, `data()`, and `headerData()` to OCaml closures.
- Zero data copying: tabular data stored in OCaml memory (arrays of records, tuples, Hashtbls, or immutable trees) is rendered directly by Qt views on demand.
- Provides `notify_reset` and `notify_data_changed` to signal view updates when OCaml state changes.

---

## 7. Declarative & Reactive Functional UI DSL (`Dsl`)

Phase 5 introduces a reactive programming layer on top of the imperative bindings:

```ocaml
module State : sig
  type 'a t
  val create : 'a -> 'a t
  val get : 'a t -> 'a
  val set : 'a t -> 'a -> unit
  val update : 'a t -> ('a -> 'a) -> unit
  val subscribe : 'a t -> ('a -> unit) -> unit
  val map : ('a -> 'b) -> 'a t -> 'b t
  val map2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
end
```

### 7.1 Oscillation-Free Bidirectional Data Binding
For input widgets (`LineEdit`, `Slider`, `CheckBox`, etc.), changing the UI updates the bound `State.t`, and programmatically changing the `State.t` updates the UI. To prevent infinite cycles:
1. `State.set` checks equality (`s.value <> new_val`) before notifying listeners.
2. The widget's subscriber checks if the current widget value matches before calling the Qt setter (e.g. `if LineEdit.text edit <> v then LineEdit.set_text edit v`).
3. The widget's event listener checks if the `State.t` value matches before calling `State.set`.

### 7.2 Zero-Flicker Conditional Views (`cond` and `match_s`)
Dynamic UI switches (`cond` and `match_s`) are backed by `QStackedWidget`. All branches are mounted ahead of time into pages, and state updates trigger page switches without layout recalculation delays or window flicker.
