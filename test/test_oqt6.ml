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

  (* 6. Test CheckBox *)
  let cb = CheckBox.create ~text:"Enable Feature" ~parent:win () in
  assert (Object.is_valid cb);
  assert (not (CheckBox.is_checked cb));
  assert (CheckBox.text cb = "Enable Feature");
  let cb_toggled = ref false in
  CheckBox.on_toggled cb (fun checked -> cb_toggled := checked);
  CheckBox.set_checked cb true;
  assert (CheckBox.is_checked cb);
  assert (!cb_toggled);

  (* 7. Test RadioButton *)
  let rb = RadioButton.create ~text:"Option A" ~parent:win () in
  assert (Object.is_valid rb);
  assert (not (RadioButton.is_checked rb));
  RadioButton.set_checked rb true;
  assert (RadioButton.is_checked rb);

  (* 8. Test ComboBox *)
  let combo = ComboBox.create ~parent:win () in
  assert (Object.is_valid combo);
  ComboBox.add_items combo ["Apple"; "Banana"; "Cherry"];
  assert (ComboBox.count combo = 3);
  assert (ComboBox.current_index combo = 0);
  assert (ComboBox.current_text combo = "Apple");
  let combo_changed = ref "" in
  ComboBox.on_current_text_changed combo (fun s -> combo_changed := s);
  ComboBox.set_current_index combo 2;
  assert (ComboBox.current_index combo = 2);
  assert (ComboBox.current_text combo = "Cherry");
  assert (!combo_changed = "Cherry");

  (* 9. Test SpinBox *)
  let sb = SpinBox.create ~parent:win () in
  assert (Object.is_valid sb);
  SpinBox.set_range sb ~min:10 ~max:100;
  SpinBox.set_single_step sb 5;
  SpinBox.set_prefix sb "$";
  SpinBox.set_suffix sb " USD";
  let spin_changed = ref 0 in
  SpinBox.on_value_changed sb (fun v -> spin_changed := v);
  SpinBox.set_value sb 45;
  assert (SpinBox.value sb = 45);
  assert (!spin_changed = 45);

  (* 10. Test Slider *)
  let slider = Slider.create ~orientation:`Horizontal ~parent:win () in
  assert (Object.is_valid slider);
  Slider.set_range slider ~min:0 ~max:100;
  let slider_changed = ref 0 in
  Slider.on_value_changed slider (fun v -> slider_changed := v);
  Slider.set_value slider 75;
  assert (Slider.value slider = 75);
  assert (!slider_changed = 75);

  (* 11. Test ProgressBar *)
  let pb = ProgressBar.create ~parent:win () in
  assert (Object.is_valid pb);
  ProgressBar.set_range pb ~min:0 ~max:100;
  ProgressBar.set_value pb 50;
  assert (ProgressBar.value pb = 50);

  (* 12. Test TextEdit *)
  let te = TextEdit.create ~text:"First line" ~parent:win () in
  assert (Object.is_valid te);
  assert (TextEdit.to_plain_text te = "First line");
  TextEdit.append te "Second line";
  let te_content = TextEdit.to_plain_text te in
  assert (String.length te_content > 0);
  TextEdit.set_read_only te true;
  assert (TextEdit.is_read_only te);

  (* 13. Test QGridLayout *)
  let grid_win = Widget.create () in
  let grid = Layout.Grid.create ~parent:grid_win () in
  assert (Object.is_valid grid);
  let g_btn1 = Button.create ~text:"G1" () in
  let g_btn2 = Button.create ~text:"G2" () in
  Layout.Grid.add_widget grid ~row:0 ~col:0 g_btn1;
  Layout.Grid.add_widget grid ~row:0 ~col:1 g_btn2;
  Layout.Grid.set_spacing grid 10;
  Widget.set_layout grid_win grid;

  (* 14. Test QMainWindow, QMenuBar, QMenu, QAction, QStatusBar *)
  let main_win = MainWindow.create () in
  assert (Object.is_valid main_win);
  let central = Widget.create () in
  MainWindow.set_central_widget main_win central;
  assert (Option.is_some (MainWindow.central_widget main_win));

  let mb = MainWindow.menu_bar main_win in
  assert (Object.is_valid mb);
  let file_menu = MenuBar.add_menu mb "&File" in
  assert (Object.is_valid file_menu);
  let action_open = Menu.add_action_text file_menu "&Open" in
  assert (Object.is_valid action_open);
  Action.set_shortcut action_open "Ctrl+O";
  Menu.add_separator file_menu;
  let action_exit = Menu.add_action_text file_menu "E&xit" in
  assert (Action.text action_exit = "E&xit");

  let act_triggered = ref false in
  Action.on_triggered action_open (fun _ -> act_triggered := true);

  let sb_bar = MainWindow.status_bar main_win in
  assert (Object.is_valid sb_bar);
  StatusBar.show_message sb_bar "System Ready";
  assert (StatusBar.current_message sb_bar = "System Ready");
  StatusBar.clear_message sb_bar;
  assert (StatusBar.current_message sb_bar = "");

  (* 15. Test QDialog *)
  let dlg = Dialog.create ~parent:main_win () in
  assert (Object.is_valid dlg);
  Dialog.set_modal dlg true;
  assert (Dialog.is_modal dlg);

  (* 14. Test Timer and Event Loop *)
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

  (* 15. Test memory model and cascade deletion *)
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
