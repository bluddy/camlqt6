# CamlQt6: Cross-Platform Qt 6 Bindings for OCaml

[![CI](https://github.com/bluddy/camlqt6/actions/workflows/ci.yml/badge.svg)](https://github.com/bluddy/camlqt6/actions/workflows/ci.yml)
[![OCaml 5.x](https://img.shields.io/badge/OCaml-5.x-orange.svg)](https://ocaml.org/)
[![Qt 6.x](https://img.shields.io/badge/Qt-6.x-green.svg)](https://www.qt.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

`CamlQt6` provides safe, modern, and idiomatic OCaml bindings for the **Qt 6** application framework. Designed from the ground up for **OCaml 5 Multicore**, `CamlQt6` supports both classic imperative Qt widget construction and modern functional reactive programming (FRP) with declarative UI trees.

---

## Key Highlights

- **Dual UI Paradigms:**
  - **Imperative Widgets:** Direct 1-to-1 Qt API access (`Button.create`, `Layout.VBox.create`, `Canvas.create`).
  - **Declarative & Reactive DSL (`Dsl`):** High-level component trees (`vbox`, `hbox`, `button`, `line_edit`) with reactive signals (`State.create`, `State.map`) and bidirectional data binding.
- **Lifetime Safety via Guarded Pointers:** Qt's `QPointer<QObject>` tracks C++ object lifetimes, so a destroyed widget's handle reports `Object.is_valid = false` and any further method call raises rather than crashing. `Object.delete` refuses objects that Qt owns.
- **Compile-Time Subtyping via Phantom Variants:** Zero-overhead polymorphic variants (`` `[> `QWidget] t` ``) let a `QPushButton` be passed anywhere a `QWidget` is expected without runtime casts. See [the honest caveat](#honest-caveats) on the one escape hatch this needs.
- **Zero-Copy Functional Table Model:** Bind OCaml data (arrays, records, maps) straight into `QTableView`. Qt calls back into OCaml on demand, so nothing is duplicated in C++. Sorting and per-cell colours/icons/alignment/tooltips are supported.
- **Custom 2D Painting & Event Trampolines:** `QPainter` with render hints (antialiasing, opacity), shapes, text, arcs/pies, polygons and pixmap blitting; `paintEvent`, mouse, keyboard, resize and drag-and-drop dispatch directly to OCaml callbacks.

### Honest caveats

Stated up front, because the rest of this document used to overclaim:

- **Multicore is cooperative, not transparent.** Callbacks from Qt into OCaml take the domain lock safely, and blocking calls (modal dialogs, `App.exec`, `Drag.exec`) release it so other domains keep running. But the *imperative* widget API does **not** marshal to the GUI thread for you — calling a widget from a worker domain is your responsibility. Use `App.run_on_ui_thread` (or `Dsl.State`, which does it for you). There is no `QThread`/`QRunnable` binding yet.
- **The phantom-variant hierarchy has one documented escape hatch.** `Core.Internal.cast` is unsound by construction; it exists because the tag is a zero-cost phantom. The *supported* API does not expose it — see `src/core.mli`.
- **`TreeView` is not zero-copy yet.** `TableModel` binds arbitrary OCaml data to `QTableView` with no copying. For `TreeView` there is only the copying `StandardItemModel`; a zero-copy `TreeModel` is not written yet. `ListView` likewise has no functional model.
- **`QPainter` has no `begin`/`end`**, so you cannot paint into a `QPixmap` outside a widget's paint event, and there is no `QImage` type, so canvas renders cannot be saved or round-tripped.
- **`Dsl` is auto-wiring, not a retained-mode framework.** There is no reconciliation or diffing: `Dsl.mount` builds the widget tree once, and only the individual two-way bindings are reactive. `cond`/`match_s` mount every branch eagerly into a `QStackedWidget`.

---

## Architecture at a Glance

For full architectural details, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).
For a step-by-step tutorial, see [docs/TUTORIAL.md](docs/TUTORIAL.md).

---

## Project Scope & Design Philosophy

`CamlQt6` is intentionally scoped to provide a premier, native **desktop GUI programming** experience for OCaml.

### What is In Scope: Native Desktop GUI & Functional Reactivity
- **Complete Native GUI Workflows:** Core windows (`QMainWindow`), layouts (`VBox`, `HBox`, `Grid`), controls (`Button`, `LineEdit`, `TextEdit`, `ComboBox`, `Slider`, `SpinBox`, etc.), and complex containers (`TabWidget`, `StackedWidget`, `Splitter`, `ScrollArea`, `GroupBox`).
- **Declarative & Reactive UI:** Modern component tree builder (`Dsl`) with reactive state primitives (`State.create`, `State.map`), bidirectional widget synchronization, and dynamic switching (`cond`, `match_s`).
- **Data-Dense Model/View Architecture:** Tables, trees, lists, and a zero-copy functional `TableModel` that exposes native OCaml data structures to `QTableView` without copying, with sorting and per-cell styling. Trees use the copying `StandardItemModel`; a zero-copy `TreeModel` is not written yet.
- **Custom 2D Vector Painting & Canvas:** `QPainter` support (lines, shapes, arcs, polygons, text, render hints, opacity, affine transforms, pixmap blitting) and virtual event trampolines (`paintEvent`, mouse, keyboard, resize, drag & drop). `QPainter.begin`/`end` and clipping are not bound.
- **Desktop System Integrations:** Native file pickers, message boxes with typed answers, color/font dialogs, system clipboard (`Clipboard`), and drag-and-drop protocols (`Drag`, `MimeData`).
- **Multicore Safety:** Re-entrant lock handling (`CamlDomainLockGuard`) that coordinates Qt callbacks and blocking calls safely with OCaml 5 runtime domains. Marshalling to the GUI thread is available via `App.run_on_ui_thread` but is not automatic — see [Honest caveats](#honest-caveats).

### What is Intentionally Out of Scope (and Why)
- **`QtNetwork`:** Network I/O is far better served by native OCaml asynchronous libraries (such as `eio`, `cohttp`, `piaf`, or `curl`) without crossing the C++ FFI boundary.
- **`QtSql`:** Relational database access in OCaml is idiomatic, type-safe, and mature using native libraries like `caqti` or `pgx`.
- **`QtSvg`:** Vector graphics rendering in CamlQt6 is natively powered by `QPainter`. Specialized SVG DOM manipulation is outside the core GUI widget scope.
- **`QML` / `QtQuick`:** QML has its own runtime engine and is already wrapped for OCaml by `lablqml`. CamlQt6 focuses on native desktop widgets and its own lightweight OCaml functional reactive DSL.
- **Peripheral Hardware Stacks (`QtBluetooth`, `QtSensors`, `QtSerialPort`):** These introduce heavy platform-dependent dependencies rarely needed for desktop user interfaces.

### Agent-Driven Engineering vs. Automated Code Generation
Rather than running an automated Clang AST generator that spits out thousands of mechanical, unidiomatic C-style wrappers (flat argument lists, integer enum codes, manual pointer casting), `CamlQt6` was built using **agent-driven engineering**:
1. **Zero-Overhead Compile-Time Subtyping:** Uses phantom polymorphic variants (`` `[> `QWidget ] Core.t` ``), allowing any widget subclass to be used in layouts or parent containers without manual runtime casts. The one escape hatch this requires, `Core.Internal.cast`, is not part of the supported API.
2. **Polymorphic Variants for Enums:** Typed, expressive variants (e.g. `` `Left_button``, `` `Solid_line``, `` `Stretch``) replace raw C++ enum integers. Every encoding is mapped with named Qt constants rather than positional integers.
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
# Build the library and the seven demo executables
opam exec -- dune build

# Run the headless test suite (224 checks across 35 groups)
opam exec -- dune runtest
```

The test suite sets `QT_QPA_PLATFORM=offscreen` itself (see `test/dune`), so it needs no
display. On Windows it also works through a real `dune build` with no manual `QTDIR` — see
[Windows Testing & Setup Guide](docs/WINDOWS_TESTING.md).

If `dune build` cannot find Qt, the configure step prints a diagnostic naming every location it
probed. Set `QTDIR` to your Qt 6 prefix to override discovery.

---

## Project Status

`0.1.0`, unreleased. The FFI and API surface are stable enough to build real applications against;
the API is not yet frozen and breaking changes are expected. A full audit of the current state —
including known weaknesses and their severity — is in [docs/CODE_REVIEW.md](docs/CODE_REVIEW.md).

## Code Examples

### Declarative & Reactive Style (`Dsl`)

```ocaml
open CamlQt6

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
open CamlQt6

let () =
  let app = App.create () in
  let win = Widget.create () in
  Widget.set_window_title win "Imperative CamlQt6";
  Widget.resize win ~width:350 ~height:200;

  let layout = Layout.VBox.create ~parent:win () in
  let label = Label.create ~text:"Welcome to CamlQt6!" () in
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
| **Declarative DSL** | `Dsl.vbox`, `hbox`, `grid`, `split`, `tabs`, `scroll`, `group`, `cond`, `match_s`, `spacing`, `stretch`, `canvas`, `custom`, `mount`, `run` |
| **Reactive State** | `Dsl.State` (`create`, `get`, `set`, `update`, `subscribe`, `subscribe_handle`, `unsubscribe`, `map`, `map2`; optional `?eq`) |
| **Containers & Docks**| `TabWidget`, `StackedWidget`, `Splitter`, `ScrollArea`, `GroupBox`, `ToolBar`, `DockWidget`, `MainWindow` |
| **Input Controls** | `Button`, `CheckBox`, `RadioButton`, `ComboBox`, `SpinBox`, `Slider`, `ProgressBar`, `LineEdit`, `TextEdit` |
| **Model / View** | `TableView`, `TreeView`, `ListView`, `HeaderView`, `ItemSelectionModel`, `StandardItemModel`, and `TableModel` (zero-copy, with `~sort` and per-cell `~foreground` / `~background` / `~alignment` / `~decoration` / `~tooltip`). No zero-copy `TreeModel` yet. |
| **2D Vector Graphics**| `Canvas`, `Painter` (lines, rects, rounded rects, ellipses, arcs, pies, polylines, polygons, text, pixmaps, `bounding_rect`, render hints, opacity, affine transforms). No `begin`/`end`, no clipping, no gradients. |
| **Desktop Dialogs** | `ColorDialog`, `FontDialog`, `InputDialog`, `ProgressDialog`, `FileDialog`, `MessageBox` (typed `answer`, configurable buttons), `Dialog` (typed `exec` result) |
| **Desktop Integration** | `Clipboard` (text, pixmap, mime, `dataChanged`), `Drag`, `MimeData`, Drop Event Trampolines (`Canvas`, `Widget.set_accept_drops`) |
| **Imaging & Assets** | `Pixmap`, `Icon` (file, pixmap, system theme), `Cursor` (typed shapes) |
| **Styling** | `Color` (RGB/HSV/HSL, hex, lighten/darken), `Font` (weight, underline, strikeout, letter spacing), `Pen` (6 styles, cap/join, dash patterns), `Brush` (6 patterns) |
| **Core & Concurrency**| `App` (`exec`, `process_events`, `post_task`, `run_on_ui_thread`), `Widget`, `Object` (lifetime tracking, safe `delete`), `Timer` (single-shot, repeating) |

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

- [Architecture & Design Details](docs/ARCHITECTURE.md)
- [Cookbook & Tutorial Guide](docs/TUTORIAL.md)
- [Windows Testing & Setup Guide](docs/WINDOWS_TESTING.md)
- [Project Roadmap & Completed Milestones](ROADMAP.md)

---

## License

This project is licensed under the MIT License.
