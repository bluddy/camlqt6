# OQt6: Cross-Platform Qt 6 Bindings for OCaml

`oqt6` provides type-safe, idiomatic OCaml bindings for the **Qt 6** application framework, supporting Linux, Windows, and macOS.

---

## Features

- **OCaml 5 Multicore Compatible:** Safe integration with OCaml 5's domain lock via re-entrant lock guards (`CamlDomainLockGuard`), allowing background threads and signals to safely call OCaml closures without deadlocks.
- **Safe Memory Management:** Leverages Qt's `QPointer<QObject>` guarded pointer system. Parent-child widget destruction cascades automatically, preventing both use-after-free and double-free errors.
- **Subtyping via Phantom Types:** Polymorphic variants (`[> `QWidget ] t`, `[> `QObject ] t`) allow widgets like `QPushButton` to be passed anywhere a `QWidget` or `QObject` is accepted without manual upcasting or runtime overhead.
- **Reactive Signals & Slots:** Connect Qt signals (`clicked`, `textChanged`, `timeout`, `returnPressed`) directly to OCaml lambdas.
- **Cross-Platform Build System:** Configured via Dune and `dune-configurator`, discovering Qt 6 through `pkg-config` on Linux/macOS with manual environment variable overrides (`OQT6_CFLAGS`, `OQT6_LIBS`) for Windows.

---

## Directory Structure

```
oqt6/
├── config/              # dune-configurator discovery script
│   ├── discover.ml
│   └── dune
├── src/                 # Library source code
│   ├── core.mli / .ml   # Core types, QObject, QTimer, memory management
│   ├── gui.mli / .ml    # GUI foundations (colors, fonts, painters)
│   ├── widgets.mli / .ml# Widgets, layouts, QApplication
│   ├── oqt6.mli / .ml   # Top-level unified namespace
│   ├── oqt6_stubs.h     # C++ header for stubs & runtime lock guards
│   ├── oqt6_stubs.cpp   # C++ bridge connecting to Qt6
│   └── dune
├── test/                # Automated headless test suite
│   ├── test_oqt6.ml
│   └── dune
├── examples/            # Interactive desktop examples
│   ├── hello.ml         # Demo showcasing inputs, buttons, timers & styles
│   └── dune
└── dune-project
```

---

## Quickstart

### 1. Requirements

- OCaml `>= 5.0.0` (using the `default` opam switch)
- Dune `>= 3.13`
- Qt 6 Development libraries:
  - Ubuntu/Debian/WSL2: `sudo apt install qt6-base-dev qt6-base-dev-tools`
  - macOS (Homebrew): `brew install qt@6`
  - Windows: Qt 6 MSVC/MinGW toolchain

### 2. Building & Testing

Run the automated headless test suite:
```bash
dune runtest
```

### 3. Running the Demo Application

Launch the interactive GUI window (on WSL2, this will display on your Windows 11 desktop via WSLg):
```bash
dune exec examples/hello.exe
```

---

## Code Example

```ocaml
open Oqt6

let () =
  let app = App.create () in
  let win = Widget.create () in
  Widget.set_window_title win "OQt6 Demo";
  Widget.resize win ~width:400 ~height:300;

  let layout = Layout.VBox.create ~parent:win () in

  let label = Label.create ~text:"Hello, Qt6 from OCaml!" () in
  Layout.add_widget layout label;

  let btn = Button.create ~text:"Click Me" () in
  Layout.add_widget layout btn;

  Button.on_clicked btn (fun () ->
    Label.set_text label "Button clicked!"
  );

  Widget.show win;
  exit (App.exec app)
```
