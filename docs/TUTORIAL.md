# CamlQt6 Tutorial & Guide

Welcome to the **CamlQt6** tutorial! This guide covers building desktop applications in OCaml with Qt 6, from basic windows to custom 2D painting, zero-copy data tables, and modern reactive declarative UIs.

---

## 1. Quickstart & Installation

### System Dependencies
- **Ubuntu / Debian / WSL2:**
  ```bash
  sudo apt update
  sudo apt install -y qt6-base-dev qt6-base-dev-tools build-essential
  ```
- **macOS:**
  ```bash
  brew install qt@6
  ```

### Building the Library
Make sure you are on the `default` switch (OCaml 5.x):
```bash
opam exec -- dune build
opam exec -- dune runtest
```

---

## 2. Hello World: Imperative API

The imperative API provides direct, 1-to-1 access to Qt's widgets and layouts:

```ocaml
open CamlQt6

let () =
  let app = App.create () in
  let win = Widget.create () in
  Widget.set_window_title win "My First CamlQt6 App";
  Widget.resize win ~width:350 ~height:200;

  (* Set up a vertical box layout *)
  let layout = Layout.VBox.create ~parent:win () in

  let label = Label.create ~text:"Welcome to CamlQt6!" () in
  Layout.add_widget layout label;

  let btn = Button.create ~text:"Click Me" () in
  Layout.add_widget layout btn;

  Button.on_clicked btn (fun () ->
    Label.set_text label "Button Clicked!"
  );

  Widget.show win;
  exit (App.exec app)
```

---

## 3. Declarative & Reactive Programming (`Dsl`)

Rather than manually instantiating widgets and managing callbacks, the `Dsl` module allows building interfaces declaratively with automatic reactive state synchronization.

### 3.1 Reactive Signals (`State`)
```ocaml
open CamlQt6

let count = State.create 0

(* Derived reactive state *)
let message = State.map (fun n -> Printf.sprintf "Clicked %d times" n) count

(* Update state *)
State.update count (fun n -> n + 1)
```

### 3.2 Declarative Counter Example
```ocaml
open CamlQt6

let () =
  let count = State.create 0 in
  let count_text = State.map (fun n -> Printf.sprintf "Current Count: %d" n) count in

  let ui =
    Dsl.window ~title:"Reactive Counter" ~width:300 ~height:180 (
      Dsl.vbox ~spacing:12 ~margin:20 [
        Dsl.label_s ~style:"font-size: 14pt; font-weight: bold;" count_text;
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

### 3.3 Bidirectional Form Binding & Conditional Views
```ocaml
open CamlQt6

let () =
  let name = State.create "" in
  let agrees = State.create false in
  let can_submit = State.map2 (fun n a -> String.trim n <> "" && a) name agrees in

  let ui =
    Dsl.window ~title:"Form Binding" ~width:400 ~height:250 (
      Dsl.vbox ~spacing:10 ~margin:16 [
        Dsl.label "Enter your name:";
        Dsl.line_edit ~placeholder:"Your name..." ~text:name ();
        Dsl.check_box ~checked:agrees "I accept the terms and conditions";

        (* Conditionally display a message *)
        Dsl.cond agrees
          ~true_node:(Dsl.label ~style:"color: green;" "Terms accepted.")
          ~false_node:(Dsl.label ~style:"color: red;" "You must accept terms to proceed.");

        Dsl.button ~enabled_s:can_submit ~on_click:(fun () ->
          print_endline ("Submitted: " ^ State.get name)
        ) "Submit";
      ]
    )
  in
  exit (Dsl.run ui)
```

---

## 4. Custom 2D Painting & Interactive Canvas

The `Canvas` widget exposes C++ virtual method trampolines directly to OCaml:

```ocaml
open CamlQt6

let () =
  let app = App.create () in
  let win = Widget.create () in
  let canvas = Canvas.create ~parent:win () in
  Canvas.set_mouse_tracking canvas true;

  let pos = ref (100, 100) in

  Canvas.on_paint canvas (fun painter ->
    Painter.set_pen painter (Pen.create ~color:(Color.rgb 52 152 219 ()) ~width:3 ());
    Painter.set_brush painter (Brush.create ~color:(Color.rgb 241 196 15 ()) ());
    let (x, y) = !pos in
    Painter.draw_rounded_rect painter ~x:(x - 40) ~y:(y - 40) ~width:80 ~height:80 ~x_radius:10.0 ~y_radius:10.0;
    Painter.draw_text painter ~x:(x - 30) ~y:(y + 5) "Dragging"
  );

  Canvas.on_mouse_move canvas (fun ev ->
    pos := (ev.x, ev.y);
    Canvas.update canvas
  );

  Widget.resize win ~width:500 ~height:400;
  Widget.show win;
  exit (App.exec app)
```

---

## 5. High-Performance Model/View Tables

`CamlQt6` supports zero-copy functional table models without duplicating OCaml memory into C++:

```ocaml
open CamlQt6

type user = { id : int; name : string; role : string }

let users = [|
  { id = 1; name = "Alice"; role = "Admin" };
  { id = 2; name = "Bob"; role = "Engineer" };
  { id = 3; name = "Charlie"; role = "Designer" };
|]

let () =
  let app = App.create () in
  let win = Widget.create () in
  let table = TableView.create ~parent:win () in

  let model = TableModel.create
    ~row_count:(fun () -> Array.length users)
    ~col_count:(fun () -> 3)
    ~data:(fun r c ->
      let u = users.(r) in
      match c with 0 -> string_of_int u.id | 1 -> u.name | _ -> u.role)
    ~header_data:(fun sec orient ->
      if orient = `Horizontal then
        match sec with 0 -> "ID" | 1 -> "Name" | _ -> "Role"
      else string_of_int (sec + 1))
    ()
  in

  TableView.set_model table model;
  TableView.set_alternating_row_colors table true;
  TableView.resize_columns_to_contents table;

  Widget.resize win ~width:450 ~height:250;
  Widget.show win;
  exit (App.exec app)
```

---

## 6. Standard Desktop Dialogs

Modal dialogs automatically release the OCaml domain lock, allowing other domains to run while awaiting user input:

```ocaml
open CamlQt6

(* Color Dialog *)
let pick_color parent =
  match ColorDialog.get_color ~parent ~title:"Select Color" () with
  | Some c -> Printf.printf "Selected: rgb(%d, %d, %d)\n%!" (Color.red c) (Color.green c) (Color.blue c)
  | None -> print_endline "Cancelled"

(* Font Dialog *)
let pick_font parent =
  match FontDialog.get_font ~parent ~title:"Select Font" () with
  | Some f -> Printf.printf "Font: %s %dpt\n%!" (Font.family f) (Font.point_size f)
  | None -> print_endline "Cancelled"

(* Input Dialogs *)
let ask_user parent =
  match InputDialog.get_text ~parent ~title:"Login" ~label:"Username:" () with
  | Some u -> Printf.printf "User: %s\n%!" u
  | None -> print_endline "Cancelled"
```

---

## 7. Interactive Demos Gallery

Run any of the included demonstrations:

| Demo | Command | Description |
| :--- | :--- | :--- |
| **Hello World** | `dune exec examples/hello.exe` | Basic inputs, buttons, sliders, and timers. |
| **Kitchen Sink** | `dune exec examples/kitchen_sink.exe` | Full widget catalog: combo, spin, radio, menus, and dialogs. |
| **Drawing Canvas** | `dune exec examples/drawing_canvas.exe` | Vector painting app with live dashed preview and transforms. |
| **Table View Demo**| `dune exec examples/table_view_demo.exe` | Interactive employee directory with sorting and headers. |
| **Workbench IDE** | `dune exec examples/workbench_demo.exe` | Full desktop IDE with docks, splitters, tabs, toolbar, and dialogs. |
| **Declarative Todo**| `dune exec examples/declarative_todo.exe`| Reactive state-driven todo and dashboard app built with `Dsl`. |
