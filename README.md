# OQt6: Cross-Platform Qt 6 Bindings for OCaml

[![OCaml 5.x](https://img.shields.io/badge/OCaml-5.x-orange.svg)](https://ocaml.org/)
[![Qt 6.x](https://img.shields.io/badge/Qt-6.x-green.svg)](https://www.qt.io/)
[![Build & Test](https://img.shields.io/badge/Tests-Passing%20(39%2F39)-brightgreen.svg)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

`oqt6` provides safe, modern, and idiomatic OCaml bindings for the **Qt 6** application framework. Designed from the ground up for **OCaml 5 Multicore**, `oqt6` supports both classic imperative Qt widget construction and modern functional reactive programming (FRP) with declarative UI trees.

---

## Key Highlights

- **Dual UI Paradigms:**
  - **Imperative Widgets:** Direct 1-to-1 Qt API access (`Button.create`, `Layout.VBox.create`, `Canvas.create`).
  - **Declarative & Reactive DSL (`Dsl`):** High-level component trees (`vbox`, `hbox`, `button`, `line_edit`) with reactive signals (`State.create`, `State.map`) and bidirectional data binding.
- **OCaml 5 Multicore & Domain-Lock Safe:** Re-entrant lock guards (`CamlDomainLockGuard`) ensure background threads and Qt signals dispatch into OCaml without deadlocks. Blocking modal dialogs safely release the runtime domain lock.
- **Memory Safety via Guarded Pointers:** Uses Qt's `QPointer<QObject>` to automatically track C++ object lifetimes. Parent-child destruction cascades cleanly without double-free or dangling pointer bugs.
- **Compile-Time Subtyping via Phantom Variants:** Zero-overhead phantom polymorphic variants (`[> `QWidget ] t`) allow widgets like `QPushButton` or `QSplitter` to be passed anywhere a `QWidget` is expected without runtime casts.
- **Zero-Copy Functional Model/View:** Directly bind in-memory OCaml data structures (arrays of records, tuples, maps) into `QTableView`, `QTreeView`, and `QListView` with zero C++ data duplication.
- **Custom 2D Painting & Event Trampolines:** Virtual method trampolines (`paintEvent`, mouse, keyboard, resize) dispatch directly to OCaml drawing callbacks using `QPainter`.

---

## Architecture at a Glance

For full architectural details, see [docs/ARCHITECTURE.md](file:///home/yotam/source/ocaml/oqt6/docs/ARCHITECTURE.md).
For a step-by-step tutorial, see [docs/TUTORIAL.md](file:///home/yotam/source/ocaml/oqt6/docs/TUTORIAL.md).

---

## Project Scope & Design Philosophy

`oqt6` is intentionally scoped to provide a premier, native **desktop GUI programming** experience for OCaml.

### What is In Scope: Native Desktop GUI & Functional Reactivity
- **Complete Native GUI Workflows:** Core windows (`QMainWindow`), layouts (`VBox`, `HBox`, `Grid`), controls (`Button`, `LineEdit`, `TextEdit`, `ComboBox`, `Slider`, `SpinBox`, etc.), and complex containers (`TabWidget`, `StackedWidget`, `Splitter`, `ScrollArea`, `GroupBox`).
- **Declarative & Reactive UI:** Modern component tree builder (`Dsl`) with reactive state primitives (`State.create`, `State.map`), bidirectional widget synchronization, and dynamic switching (`cond`, `match_s`).
- **Data-Dense Model/View Architecture:** Tables, trees, lists, and a zero-copy functional `TableModel` that directly exposes native OCaml data structures to Qt views without copying.
- **Custom 2D Vector Painting & Canvas:** Full `QPainter` support (lines, shapes, text, affine transforms, pixmap blitting) and virtual event trampolines (`paintEvent`, mouse, keyboard, resize, drag & drop).
- **Desktop System Integrations:** Native file pickers, message boxes, color/font dialogs, system clipboard (`Clipboard`), and drag-and-drop protocols (`Drag`, `MimeData`).
- **Multicore Safety:** Re-entrant lock handling (`CamlDomainLockGuard`) that coordinates safely with OCaml 5 runtime domains.

### What is Intentionally Out of Scope (and Why)
- **`QtNetwork`:** Network I/O is far better served by native OCaml asynchronous libraries (such as `eio`, `cohttp`, `piaf`, or `curl`) without crossing the C++ FFI boundary.
- **`QtSql`:** Relational database access in OCaml is idiomatic, type-safe, and mature using native libraries like `caqti` or `pgx`.
- **`QtSvg`:** Vector graphics rendering in OQt6 is natively powered by `QPainter`. Specialized SVG DOM manipulation is outside the core GUI widget scope.
- **`QML` / `QtQuick`:** QML has its own runtime engine and is already wrapped for OCaml by `lablqml`. OQt6 focuses on native desktop widgets and its own lightweight OCaml functional reactive DSL.
- **Peripheral Hardware Stacks (`QtBluetooth`, `QtSensors`, `QtSerialPort`):** These introduce heavy platform-dependent dependencies rarely needed for desktop user interfaces.

### Agent-Driven Engineering vs. Automated Code Generation
Rather than running an automated Clang AST generator that spits out thousands of mechanical, unidiomatic C-style wrappers (flat argument lists, integer enum codes, manual pointer casting), `oqt6` was built using **agent-driven engineering**:
1. **Zero-Overhead Compile-Time Subtyping:** Uses phantom polymorphic variants (`[> `QWidget ] Core.t`), allowing any widget subclass to be used in layouts or parent containers without manual runtime casts.
2. **Polymorphic Variants for Enums:** Typed, expressive variants (e.g. `` `Left_button``, `` `Solid_line``, `` `Stretch``) replace raw C++ enum integers.
3. **No Generator Dependencies:** The repository contains clean, human-auditable C++ stubs and OCaml source. It builds in seconds with standard `dune build` and zero external generator toolchains.

---

## Quickstart

### 1. Requirements

- OCaml `>= 5.0.0`
- Dune `>= 3.13`
- Qt 6 Base Development Libraries:
  - **Ubuntu / Debian / WSL2:** `sudo apt install -y qt6-base-dev qt6-base-dev-tools build-essential`
  - **macOS:** `brew install qt@6`
  - **Windows:** Qt 6 MSVC or MinGW toolchain

### 2. Building & Testing

```bash
# Build the entire library and examples
opam exec -- dune build

# Run the 34-case automated headless test suite
opam exec -- dune runtest
```

---

## Code Examples

### Declarative & Reactive Style (`Dsl`)

```ocaml
open Oqt6

let () =
  let count = State.create 0 in
  let summary = State.map (fun n -> Printf.sprintf "Count: %d" n) count in

  let ui =
    Dsl.window ~title:"Declarative Counter" ~width:320 ~height:200 (
      Dsl.vbox ~spacing:12 ~margin:16 [
        Dsl.label_s ~style:"font-size: 16pt; font-weight: bold;" summary;
        Dsl.hbox ~spacing:8 [
          Dsl.button ~on_click:(fun () -> State.update count (fun n -> n - 1)) "- Decrement";
          Dsl.button ~on_click:(fun () -> State.update count (fun n -> n + 1)) "+ Increment";
        ];
        Dsl.button ~on_click:(fun () -> State.set count 0) "Reset";
      ]
    )
  in

  exit (Dsl.run ui)
```

### Direct Imperative Style

```ocaml
open Oqt6

let () =
  let app = App.create () in
  let win = Widget.create () in
  Widget.set_window_title win "Imperative OQt6";
  Widget.resize win ~width:350 ~height:200;

  let layout = Layout.VBox.create ~parent:win () in
  let label = Label.create ~text:"Welcome to OQt6!" () in
  let btn = Button.create ~text:"Click Me" () in

  Layout.add_widget layout label;
  Layout.add_widget layout btn;

  Button.on_clicked btn (fun () ->
    Label.set_text label "Button clicked!"
  );

  Widget.show win;
  exit (App.exec app)
```

---

## Feature Matrix

| Category | Modules / Components |
| :--- | :--- |
| **Declarative DSL** | `Dsl.vbox`, `hbox`, `grid`, `split`, `tabs`, `scroll`, `group`, `cond`, `match_s`, `spacing`, `stretch`, `mount`, `run` |
| **Reactive State** | `Dsl.State` (`create`, `get`, `set`, `update`, `subscribe`, `map`, `map2`) |
| **Containers & Docks**| `TabWidget`, `StackedWidget`, `Splitter`, `ScrollArea`, `GroupBox`, `ToolBar`, `DockWidget`, `MainWindow` |
| **Input Controls** | `Button`, `CheckBox`, `RadioButton`, `ComboBox`, `SpinBox`, `Slider`, `ProgressBar`, `LineEdit`, `TextEdit` |
| **Model / View** | `TableView`, `TreeView`, `ListView`, `HeaderView`, `ItemSelectionModel`, `StandardItemModel`, `TableModel` (functional zero-copy) |
| **2D Vector Graphics**| `Canvas`, `Painter` (lines, rects, rounded rects, ellipses, text, pixmaps, affine transforms: translate/scale/rotate) |
| **Desktop Dialogs** | `ColorDialog`, `FontDialog`, `InputDialog`, `ProgressDialog`, `FileDialog`, `MessageBox`, `Dialog` |
| **Desktop Integration** | `Clipboard` (text, pixmap, signals), `Drag`, `MimeData`, Drop Event Trampolines (`Canvas`, `Widget.set_accept_drops`) |
| **Imaging & Assets** | `Pixmap`, `Icon` (file, pixmap, system theme), `Cursor` (typed shapes) |
| **Core & Concurrency**| `App`, `Widget`, `Object` (lifetime tracking, delete), `Timer` (single-shot, repeating) |

---

## Interactive Demo Gallery

Run any of the included demonstrations directly:

```bash
# Declarative To-Do and Reactive Dashboard (Phase 5)
opam exec -- dune exec examples/declarative_todo.exe

# Developer Workbench with Docks, Toolbars, Splitters & Dialogs (Phase 4)
opam exec -- dune exec examples/workbench_demo.exe

# High-Performance Data Table with Functional Model (Phase 3)
opam exec -- dune exec examples/table_view_demo.exe

# Vector Paint Canvas with Live Drawing Preview & Affine Transforms (Phase 2)
opam exec -- dune exec examples/drawing_canvas.exe

# Complete Standard Widget Catalog (Phase 1)
opam exec -- dune exec examples/kitchen_sink.exe

# Drag, Drop & System Clipboard Studio
opam exec -- dune exec examples/drag_drop_demo.exe

# Minimal Hello World
opam exec -- dune exec examples/hello.exe
```

---

## Documentation Links

- [Architecture & Design Details](file:///home/yotam/source/ocaml/oqt6/docs/ARCHITECTURE.md)
- [Cookbook & Tutorial Guide](file:///home/yotam/source/ocaml/oqt6/docs/TUTORIAL.md)
- [Windows Testing & Setup Guide](file:///home/yotam/source/ocaml/oqt6/docs/WINDOWS_TESTING.md)
- [Project Roadmap & Completed Milestones](file:///home/yotam/source/ocaml/oqt6/ROADMAP.md)

---

## License

This project is licensed under the MIT License.
