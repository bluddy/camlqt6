# OQt6: Comprehensive Development Plan & Architecture

This document outlines the strategy for expanding **OQt6** into a full-featured, cross-platform Qt 6 binding for OCaml.

---

## 1. Code Generation vs. Agent-Driven Development

### The Scale of Qt 6
Qt 6 is one of the largest application frameworks in existence:
- **~1,000+ classes** across Core, Gui, Widgets, Network, Qml/Quick, Svg, Sql, etc.
- **~30,000+ methods** and thousands of enum values.
- Ongoing minor version updates (Qt 6.6, 6.7, 6.8, etc.).

### Why Pure Agent Manual Coding Falls Short for Everything
- **Token Inefficiency:** Writing 30,000 C++/OCaml stubs manually would require millions of tokens and dozens of repetitive sessions.
- **Subtle Drift & Typos:** Over hundreds of files, manual coding invites inconsistencies in naming, pointer casts, and type signatures.
- **Qt Upgrades:** When Qt adds methods or deprecates flags, an automated generator updates the entire FFI surface in seconds by re-running against the new headers.

### Why Pure Code Generation Falls Short for OCaml
- Blindly generating C++ wrappers produces an **un-idiomatic, hostile API** in OCaml:
  - C-style flat argument lists without labeled or optional arguments.
  - Raw integers instead of expressive polymorphic variants for enums and flags.
  - Manual pointer casting instead of type-safe subtyping.
  - No integration with OCaml functional idioms, domain locks, or reactive patterns.

### The Recommended Architecture: The 2-Tier "Hybrid" Engine

```mermaid
graph TD
    A["Qt 6 C++ Headers / AST"] -->|Generator Tool| B["Tier 1: Low-Level C ABI Shim & Raw FFI"]
    B --> C["OQt6 Raw Primitives (external ...)"]
    C -->|Hand-Crafted / Agent Designed| D["Tier 2: Idiomatic OCaml Layer"]
    D --> E["Subtyping via Phantom Types ([> `Tag ] t)"]
    D --> F["Signal & Slot Reactive Closures"]
    D --> G["Declarative UI DSL & Combinators"]
    D --> H["Custom Widget Overrides (QPainter, Events)"]
```

1. **Tier 1 (Automated Mechanical FFI):**
   - A deterministic generator (leveraging Clang AST parser or the proven [libqt6c/miqt](https://github.com/rcalixte/libqt6c) metadata).
   - Generates the mechanical, non-thinking C wrapper functions and raw OCaml `external` declarations.
2. **Tier 2 (High-Level Idiomatic API - Where Agents Excel):**
   - Labeled/optional arguments and sensible defaults.
   - Expressive variant types for enums and bitflags.
   - Memory ownership contracts and OCaml 5 multicore safety.
   - Declarative layout DSLs (e.g. Elm/SwiftUI-style tree builders).
   - Custom widget subclassing trampolines (e.g. `paintEvent` dispatching to OCaml canvas renderers).

---

## 2. Phased Roadmap to Full Coverage

```mermaid
flowchart LR
    P1["Phase 1: Essential Desktop UI (80/20)"] --> P2["Phase 2: Custom Drawing & Event Trampolines"]
    P2 --> P3["Phase 3: Model / View / Delegate Architecture"]
    P3 --> P4["Phase 4: Clang / Metadata Generator Pipeline"]
    P4 --> P5["Phase 5: Declarative Functional DSL"]
```

### Phase 1: Essential Desktop UI (The "80/20" Rule)
*Goal: Enable building rich, complete desktop applications with standard widgets.*

1. **Top-Level Windows & Dialogs:**
   - `QMainWindow`: Central widget, toolbars, status bar, dock widgets, menu bar.
   - `QDialog`, `QMessageBox`, `QFileDialog`, `QColorDialog`, `QFontDialog`.
2. **Complex Layouts:**
   - `QGridLayout`, `QFormLayout`, `QStackedLayout`, `QSplitter`, `QScrollArea`.
3. **Core Interactive Widgets:**
   - Input: `QCheckBox`, `QRadioButton`, `QButtonGroup`, `QComboBox`, `QSpinBox`, `QDoubleSpinBox`, `QSlider`.
   - Rich Text: `QTextEdit`, `QPlainTextEdit`.
   - Indicators: `QProgressBar`, `QLCDNumber`.
4. **Menus, Actions & Shortcuts:**
   - `QAction`, `QMenuBar`, `QMenu`, `QToolBar`, `QKeySequence`.
5. **Typed Enums & Flags:**
   - Alignment (`Align_left`, `Align_center`, `Align_right`).
   - Orientations (`Horizontal`, `Vertical`).
   - Standard colors and window flags.

---

### Phase 2: Custom Drawing & Event Trampolines
*Goal: Allow OCaml users to build custom interactive widgets and visualizations.*

Qt relies heavily on C++ virtual methods for custom behavior. We need C++ trampoline classes that forward virtual calls to OCaml closures:

1. **Trampoline Subclassing (`OCamlWidget : public QWidget`):**
   - Override `paintEvent(QPaintEvent*)` $\rightarrow$ calls OCaml drawing function.
   - Override `mousePressEvent`, `mouseReleaseEvent`, `mouseMoveEvent`.
   - Override `keyPressEvent`, `keyReleaseEvent`.
   - Override `resizeEvent`, `closeEvent`.
2. **2D Graphics & Painting (`QtGui`):**
   - `QPainter`: `draw_line`, `draw_rect`, `draw_ellipse`, `draw_text`, `draw_image`.
   - `QPen`, `QBrush`, `QColor`, `QFont`, `QPixmap`, `QImage`.

---

### Phase 3: Model / View / Delegate Architecture
*Goal: High-performance data display and tables for data-dense applications.*

1. **Views:**
   - `QTableView`, `QTreeView`, `QListView`.
2. **Models:**
   - `QStandardItemModel` (simple tree/table model).
   - `QAbstractItemModel` bridge allowing pure OCaml functional data structures (records, arrays, maps) to back a Qt table/tree with zero copying.
3. **Selection Models:**
   - `QItemSelectionModel` (current row, selected ranges, multi-selection).

---

### Phase 4: Generator Tooling for Total Coverage
*Goal: Scale out to the entire Qt 6 surface area without manual stub maintenance.*

1. **Generator Strategy:**
   - Build a generator tool using the Clang AST or the [libqt6c](https://github.com/rcalixte/libqt6c) C ABI definitions.
   - Auto-generate:
     - All remaining widget classes.
     - `QtNetwork` (`QNetworkAccessManager`, `QTcpSocket`, `QUdpSocket`).
     - `QtSvg` (`QSvgWidget`, `QSvgRenderer`).
     - `QtSql` (`QSqlDatabase`, `QSqlQuery`).
     - Remaining `QtCore` utilities (`QSettings`, `QProcess`, `QDir`, `QFileInfo`).

---

### Phase 5: Declarative / Reactive Functional UI DSL
*Goal: Provide a modern functional reactive programming (FRP) or declarative builder.*

Instead of imperative widget creation:
```ocaml
(* Imperative *)
let win = Widget.create () in
let layout = Layout.VBox.create ~parent:win () in
let btn = Button.create ~text:"Click" () in
Layout.add_widget layout btn;
```

Enable declarative composition:
```ocaml
(* Declarative UI Tree *)
let ui =
  window ~title:"OQt6 Declarative" ~size:(400, 300) [
    vbox ~spacing:10 [
      label "Enter your name:";
      line_edit ~placeholder:"Name..." ~on_change:(fun s -> ...);
      hbox [
        button ~style:`Primary ~on_click:(fun () -> ...) "Submit";
        button ~style:`Secondary ~on_click:(fun () -> ...) "Cancel";
      ];
    ]
  ]
```

---

## 3. Immediate Milestones

| Milestone | Deliverables | Target Status |
| :--- | :--- | :--- |
| **M1: Foundational Proof of Concept** | Core types, phantom subtyping, `QApplication`, `QWidget`, `QPushButton`, `QLabel`, `QLineEdit`, `QVBoxLayout`, `QTimer`, automated test suite, example app | **Completed** |
| **M2: Complete Common Widgets & Dialogs** | `QMainWindow`, `QDialog`, `QMessageBox`, `QCheckBox`, `QComboBox`, `QSlider`, `QProgressBar`, `QGridLayout` | **Ready to begin** |
| **M3: Event Trampolines & QPainter** | `OCamlWidget` C++ trampoline class, `paintEvent`, `QPainter`, `QColor`, `QFont`, custom drawing demo | Next |
| **M4: Generator Pipeline Evaluation** | Clang/JSON parser prototype to automate mechanical stubs for 100+ classes | Next |
