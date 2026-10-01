open Camlqt6

let () =
  let app = App.create () in

  let win = Widget.create () in
  Widget.set_window_title win "CamlQt6 Demo - OCaml Qt6 Bindings";
  Widget.resize win ~width:420 ~height:320;

  let layout = Layout.VBox.create ~parent:win () in

  (* Header Label *)
  let title_label = Label.create ~text:"🚀 CamlQt6: OCaml bindings for Qt 6" () in
  Widget.set_style_sheet title_label "font-size: 16px; font-weight: bold; color: #2b5c8f; margin-bottom: 8px;";
  Layout.add_widget layout title_label;

  (* Status / Timer Label *)
  let status_label = Label.create ~text:"Ready (initializing timer...)" () in
  Widget.set_style_sheet status_label "color: #666; font-style: italic;";
  Layout.add_widget layout status_label;

  (* Input field *)
  let input = LineEdit.create () in
  LineEdit.set_placeholder_text input "Type something here to test live reactive update...";
  Layout.add_widget layout input;

  (* Echo label *)
  let echo_label = Label.create ~text:"Echo: (empty)" () in
  Layout.add_widget layout echo_label;

  LineEdit.on_text_changed input (fun text ->
    let display = if String.length text = 0 then "(empty)" else text in
    Label.set_text echo_label ("Echo: " ^ display)
  );

  (* Counter Button *)
  let count = ref 0 in
  let counter_btn = Button.create ~text:"Click Me! Count: 0" () in
  Widget.set_style_sheet counter_btn "padding: 8px; font-weight: bold; background-color: #4CAF50; color: white; border-radius: 4px;";
  Layout.add_widget layout counter_btn;

  Button.on_clicked counter_btn (fun () ->
    incr count;
    Button.set_text counter_btn (Printf.sprintf "Click Me! Count: %d" !count);
    Label.set_text status_label (Printf.sprintf "Button was clicked %d time%s!" !count (if !count = 1 then "" else "s"))
  );

  (* Single shot timer *)
  Timer.single_shot 1000 (fun () ->
    Label.set_text status_label "Timer fired! Qt event loop and OCaml callbacks are working smoothly."
  );

  (* Add stretch before bottom controls *)
  Layout.add_stretch layout ();

  (* Quit button *)
  let quit_btn = Button.create ~text:"Quit Application" () in
  Widget.set_style_sheet quit_btn "padding: 6px; background-color: #e74c3c; color: white; border-radius: 4px;";
  Layout.add_widget layout quit_btn;

  Button.on_clicked quit_btn (fun () ->
    print_endline "Quit requested from OCaml callback.";
    App.quit ()
  );

  Widget.show win;
  let code = App.exec app in
  print_endline (Printf.sprintf "Application exited with code %d." code);
  exit code
