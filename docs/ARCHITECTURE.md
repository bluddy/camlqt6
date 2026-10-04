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
│        QtCore, QtGui, QtWidgets (C++17 or newer)       │
└────────────────────────────────────────────────────────┘
```

The stubs compile as **C++17** by default. `config/discover.ml` reads `CAMLQT6_CXXSTD` if you need
a different standard (`set CAMLQT6_CXXSTD=20`); it emits `/std:c++NN` under MSVC and `-std=c++NN`
elsewhere.

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

`CamlQt6` maintains a thread-local count of how many references the current thread holds on the
OCaml 5 runtime system:

```cpp
static thread_local int thread_domain_lock_depth = 0;
static thread_local bool thread_is_registered = false;
```

The invariant, which is worth stating precisely because the code depends on it:

- **`depth > 0`** — an OCaml→C++ call is in progress on this thread, so the calling OCaml frame
  already holds the runtime system. A nested `CamlDomainLockGuard` must **not** re-acquire it.
- **`depth == 0`** — we are either inside a Qt→OCaml callback or inside a `CamlBlockingSection`,
  so the runtime system **must** be acquired before touching any OCaml state.

```cpp
struct CamlDomainLockGuard {
    bool need_release;
    CamlDomainLockGuard() : need_release(false) {
        if (!thread_is_registered) {
            caml_c_thread_register();
            thread_is_registered = true;
        }
        if (thread_domain_lock_depth == 0) {
            caml_acquire_runtime_system();
            thread_domain_lock_depth++;
            need_release = true;
        }
    }
    ~CamlDomainLockGuard() {
        if (need_release) {
            thread_domain_lock_depth--;
            caml_release_runtime_system();
        }
    }
};
```

Whenever Qt invokes a signal handler or virtual method trampoline that dispatches to OCaml:
- If the current thread already holds the domain lock, depth is incremented without re-locking.
- If entering from Qt's native event loop, `caml_acquire_runtime_system()` is called safely.

`App.create` sets `depth = 1` on the calling thread, because at that point an OCaml→C++ call *is*
in progress. It also sets `thread_is_registered = true`: the OCaml main thread is already registered
with the runtime, and calling `caml_c_thread_register()` there would deadlock on the systhreads
mutex. `App.create` **must be called from the main OCaml domain** — the thread that runs the Qt
event loop — and raises a clear error if it is not, because a fabricated `depth` on a secondary
domain would suppress lock acquisition there.

### 3.2 Blocking sections (`CamlBlockingSection`)

For any Qt call that may block or run a nested event loop, the runtime system is released via an
RAII guard so other OCaml domains keep running:

```cpp
{
    CamlBlockingSection blocking_section;
    QColor res = QColorDialog::getColor(initial, parent, title);
}
```

`CamlBlockingSection` clears `depth` before releasing and restores it after re-acquiring, so a
callback arriving inside the guarded call behaves exactly as it would outside one.

**The guard must be declared in an explicit inner scope that closes before the enclosing
primitive's `CAMLreturn`.** Letting it live until function-scope exit makes its destructor run
after `CAMLreturn` has begun the function epilogue; `caml_acquire_runtime_system()` then executes
against a half-torn-down OCaml frame and the process dies with an access violation. This is
documented at the definition in `src/camlqt6_stubs.h`.

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

Functions that accept any widget use open variants (`` `[> `QWidget ] t` ``):
```ocaml
val add_widget : [> `QBoxLayout ] Core.t -> ?stretch:int -> [> `QWidget ] Core.t -> unit
```

This guarantees:
- Any `QPushButton` (`qpush_button Core.t`) can be passed directly to `Layout.add_widget` without casting.
- Passing a non-widget (e.g. `QTimer` of type `qtimer Core.t`) is rejected at compile time.
- Zero runtime overhead: all types erase to the same underlying pointer representation.
- `Widget.as_widget` provides a statically checked coercion for heterogeneous collections.

**The one caveat.** "Zero runtime overhead" is precisely what makes the tag *forgeable*: because
every instantiation erases to the same representation, OCaml cannot verify a tag at runtime, so an
internal `cast` is unavoidable — `` `[> `QWidget] t` `` cannot be narrowed to `qwidget t` by the type
checker alone, since the caller may hold a wider tag. That escape hatch therefore exists as

```ocaml
module Core.Internal : sig
  val cast : 'a t -> 'b t
end
```

It is deliberately **not** at the top level of `Core`, so it does not appear in the supported API,
and both internal uses (`Widget.as_widget`, `Dsl.bind_ui`) are commented. Making it genuinely
airtight would require a runtime-checked tag, which trades away the zero-overhead property the
whole design rests on. Accessors do validate the underlying custom block, so a mistake surfaces as
an `Invalid_argument` rather than memory corruption.

---

## 5. Event Trampolines (`OCamlCanvas`)

For custom rendering and interactive 2D graphics, `CamlQt6` implements a C++ virtual method trampoline subclass, `OCamlCanvas : public QWidget`. It is exposed to OCaml as `Widgets.qcanvas` / the `Canvas` module; the C++ class name and the OCaml phantom tag deliberately differ (`OCamlCanvas` vs `` `QCanvas ``).

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

Qt's `QAbstractItemView` classes expect a `QAbstractItemModel`. Standard bindings often serialize
data into C++ `QStandardItemModel` structures, duplicating memory.

`CamlQt6` implements `OCamlTableModel : public QAbstractTableModel`:
- Delegates `rowCount()`, `columnCount()`, `data()` and `headerData()` to OCaml closures.
- Zero data copying: tabular data stored in OCaml memory (arrays of records, tuples, maps) is
  rendered directly by Qt views on demand.
- Per-cell styling through optional `~foreground`, `~background`, `~alignment`, `~decoration` and
  `~tooltip` callbacks, each `(row, col) -> payload option`. Returning `None` means "no opinion"
  and leaves the cell with the view's own styling.
- Sorting through `~sort`. Qt's default `QAbstractItemModel::sort` is a no-op, so without an
  override `set_sorting_enabled` produces a header that *looks* sortable and silently does nothing.
  `OCamlTableModel::sort` calls back into OCaml to reorder the underlying collection, then resets
  the view.
- `notify_reset` and `notify_data_changed` to signal view updates when OCaml state changes.

`TableModel.row_count` / `column_count` / `data_at` / `header_at` query the model through Qt's own
dispatch — the same path a view takes while painting — which makes the contract observable and
testable from OCaml.

**Scope limit:** this is a *table* model. `QTreeView` and `QListView` have no zero-copy model here;
they require the copying `StandardItemModel`. A `TreeModel` is not written yet, so the "zero-copy
into `QTreeView`" claim does not hold.

---

## 7. Declarative & Reactive Functional UI DSL (`Dsl`)

A reactive layer on top of the imperative bindings:

```ocaml
module State : sig
  type 'a t
  type subscription
  val create : ?eq:('a -> 'a -> bool) -> 'a -> 'a t
  val get : 'a t -> 'a
  val set : 'a t -> 'a -> unit
  val update : 'a t -> ('a -> 'a) -> unit
  val subscribe : 'a t -> ('a -> unit) -> unit
  val subscribe_handle : 'a t -> ('a -> unit) -> subscription
  val unsubscribe : 'a t -> subscription -> unit
  val map : ?eq:('b -> 'b -> bool) -> ('a -> 'b) -> 'a t -> 'b t
  val map2 : ?eq:('c -> 'c -> bool) -> ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
end
```

### 7.1 Oscillation-Free Bidirectional Data Binding
For input widgets (`LineEdit`, `Slider`, `CheckBox`, etc.), changing the UI updates the bound
`State.t`, and programmatically changing the `State.t` updates the UI. To prevent infinite cycles:
1. `State.set` compares with the state's `eq` before notifying listeners.
2. The widget's subscriber checks if the current widget value matches before calling the Qt setter
   (e.g. `if LineEdit.text edit <> v then LineEdit.set_text edit v`).
3. The widget's event listener checks if the `State.t` value matches before calling `State.set`.

**What `eq` actually is.** It defaults to polymorphic equality (`( = )`), which is a real
limitation rather than a formality, because change detection is *load-bearing* for step 1:

| Value | Default `( = )` behaviour | Fix |
| :--- | :--- | :--- |
| `nan` | `nan = nan` is false, so **every** write notifies | `State.create ~eq:Float.equal` |
| contains a function | always false, so every write notifies | a domain-specific `eq` |
| cyclic structure | diverges | a shallow `eq` |
| large values | deep compare on every write | a key-based `eq` |

### 7.2 Zero-Flicker Conditional Views (`cond` and `match_s`)
Dynamic UI switches (`cond` and `match_s`) are backed by `QStackedWidget`. All branches are
mounted ahead of time into pages, and state updates trigger page switches without layout
recalculation delays or window flicker. The cost is that every branch's widgets and `State`
subscriptions stay alive for the lifetime of the container, whether or not it is visible.

### 7.3 What the DSL is not
`Dsl.mount` builds the widget tree **once**. There is no reconciliation, no diffing, no node
identity, and no `key`. Only the individual two-way bindings are reactive — the tree itself is not.
It is best described as imperative construction with automatic wiring and a declarative surface
syntax, not as a retained-mode framework.
