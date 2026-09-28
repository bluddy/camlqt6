open Oqt6

let () =
  print_endline "=== Starting OQt6 Test Suite ===";

  (* Initialize QApplication with offscreen platform for headless automated test *)
  let app = App.create ~args:[| "test_oqt6"; "-platform"; "offscreen" |] () in
  assert (Object.is_valid app);

  (* 1. Test Widget creation and properties *)
  let win = Widget.create () in
  assert (Object.is_valid win);
  Widget.set_window_title win "Test Window";
  assert (Widget.window_title win = "Test Window");
  Widget.resize win ~width:300 ~height:200;
  assert (Widget.width win = 300);
  assert (Widget.height win = 200);

  (* 2. Test Layout *)
  let layout = Layout.VBox.create ~parent:win () in
  assert (Object.is_valid layout);

  (* 3. Test Button *)
  let btn = Button.create ~text:"Original Button" ~parent:win () in
  assert (Object.is_valid btn);
  assert (Button.text btn = "Original Button");
  Button.set_text btn "Updated Button";
  assert (Button.text btn = "Updated Button");
  Layout.add_widget layout btn;

  (* 4. Test Label *)
  let lbl = Label.create ~text:"Initial Label" ~parent:win () in
  assert (Object.is_valid lbl);
  assert (Label.text lbl = "Initial Label");
  Label.set_text lbl "New Label Text";
  assert (Label.text lbl = "New Label Text");
  Layout.add_widget layout lbl;

  (* 5. Test LineEdit and Signals *)
  let edit = LineEdit.create ~parent:win () in
  assert (Object.is_valid edit);
  LineEdit.set_placeholder_text edit "Type...";
  assert (LineEdit.placeholder_text edit = "Type...");

  let text_changed_fired = ref false in
  let received_text = ref "" in
  LineEdit.on_text_changed edit (fun txt ->
    text_changed_fired := true;
    received_text := txt
  );

  LineEdit.set_text edit "Hello from OCaml!";
  assert (LineEdit.text edit = "Hello from OCaml!");

  (* 6. Test Timer and Event Loop *)
  let timer_fired = ref false in
  Timer.single_shot 50 (fun () ->
    timer_fired := true;
    print_endline "Timer callback executed successfully in event loop!";
    App.quit ()
  );

  Widget.show win;
  print_endline "Entering QApplication event loop...";
  let ret = App.exec app in
  assert (ret = 0);
  print_endline "Event loop exited cleanly.";

  (* Verify callbacks executed *)
  assert (!timer_fired);
  assert (!text_changed_fired);
  assert (!received_text = "Hello from OCaml!");

  (* 7. Test memory model and cascade deletion *)
  print_endline "Testing memory model and object lifetime tracking...";
  let temp_parent = Widget.create () in
  let temp_child = Button.create ~parent:temp_parent () in
  assert (Object.is_valid temp_parent);
  assert (Object.is_valid temp_child);

  (* Deleting parent should invalidate child via QPointer *)
  Object.delete temp_parent;
  assert (not (Object.is_valid temp_parent));
  assert (not (Object.is_valid temp_child));

  print_endline "=== All OQt6 Tests Passed Successfully! ==="
