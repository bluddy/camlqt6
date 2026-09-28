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

  (* 16. Test Color, Font, Pen, Brush *)
  let c = Color.rgb 255 128 64 ~alpha:200 () in
  assert (Color.red c = 255);
  assert (Color.green c = 128);
  assert (Color.blue c = 64);
  assert (Color.alpha c = 200);

  let c_name = Color.name "#123456" in
  assert (Color.red c_name = 0x12);
  assert (Color.green c_name = 0x34);
  assert (Color.blue c_name = 0x56);

  let f = Font.create ~family:"Helvetica" ~point_size:14 ~bold:true ~italic:false () in
  assert (Font.family f = "Helvetica");
  assert (Font.point_size f = 14);
  assert (Font.bold f);
  assert (not (Font.italic f));
  Font.set_family f "Courier";
  assert (Font.family f = "Courier");
  Font.set_point_size f 18;
  assert (Font.point_size f = 18);
  Font.set_bold f false;
  assert (not (Font.bold f));
  Font.set_italic f true;
  assert (Font.italic f);

  let p = Pen.create ~color:c ~width:3 ~style:`Dash_line () in
  Pen.set_color p Color.black;
  Pen.set_width p 5;
  Pen.set_style p `Dot_line;

  let b = Brush.create ~color:Color.blue_color ~style:`Solid_pattern () in
  Brush.set_color b Color.red_color;
  Brush.set_style b `No_brush;

  (* 17. Test Canvas & Painter *)
  let canvas_win = Widget.create () in
  Widget.resize canvas_win ~width:300 ~height:300;
  let canvas = Canvas.create ~parent:canvas_win () in
  assert (Object.is_valid canvas);
  Widget.resize canvas ~width:300 ~height:300;
  Canvas.set_mouse_tracking canvas true;

  let paint_count = ref 0 in
  Canvas.on_paint canvas (fun painter ->
    incr paint_count;
    Painter.set_pen painter (Pen.create ~color:Color.black ~width:2 ());
    Painter.set_brush painter (Brush.create ~color:Color.yellow ());
    Painter.set_font painter f;
    Painter.draw_line painter ~x1:0 ~y1:0 ~x2:100 ~y2:100;
    Painter.draw_rect painter ~x:10 ~y:10 ~width:50 ~height:50;
    Painter.fill_rect painter ~x:20 ~y:20 ~width:30 ~height:30 Color.green_color;
    Painter.draw_rounded_rect painter ~x:30 ~y:30 ~width:40 ~height:40 ~x_radius:5.0 ~y_radius:5.0;
    Painter.draw_ellipse painter ~x:40 ~y:40 ~width:30 ~height:30;
    Painter.draw_text painter ~x:5 ~y:15 "Canvas Text";
    Painter.save painter;
    Painter.translate painter ~dx:10.0 ~dy:10.0;
    Painter.scale painter ~sx:1.5 ~sy:1.5;
    Painter.rotate painter ~angle:45.0;
    Painter.restore painter
  );

  let mouse_tested = ref false in
  Canvas.on_mouse_press canvas (fun ev ->
    assert (ev.button = `Left_button);
    mouse_tested := true
  );
  Canvas.on_mouse_release canvas (fun _ -> ());
  Canvas.on_mouse_move canvas (fun _ -> ());
  Canvas.on_key_press canvas (fun _ -> ());
  Canvas.on_resize canvas (fun ev ->
    assert (ev.width >= 0)
  );

  Widget.show canvas_win;
  Canvas.update canvas;

  (* 18. Test StandardItemModel *)
  let std_model = StandardItemModel.create ~rows:2 ~cols:2 () in
  assert (Object.is_valid std_model);
  assert (StandardItemModel.row_count std_model = 2);
  assert (StandardItemModel.column_count std_model = 2);
  StandardItemModel.set_item std_model ~row:0 ~col:0 ~text:"Cell 0,0";
  assert (StandardItemModel.item_text std_model ~row:0 ~col:0 = "Cell 0,0");
  StandardItemModel.set_horizontal_header_labels std_model ["H1"; "H2"];
  StandardItemModel.append_row std_model ["R3C1"; "R3C2"];
  assert (StandardItemModel.row_count std_model = 3);
  StandardItemModel.remove_row std_model 0;
  assert (StandardItemModel.row_count std_model = 2);

  (* 19. Test Functional TableModel *)
  let records = [|
    ("Caml", "Functional", "1996");
    ("OCaml", "Multi-paradigm", "1996");
    ("Qt6", "C++ GUI", "2020");
  |] in
  let table_model = TableModel.create
    ~row_count:(fun () -> Array.length records)
    ~col_count:(fun () -> 3)
    ~data:(fun r c ->
      let (name, kind, year) = records.(r) in
      match c with 0 -> name | 1 -> kind | _ -> year)
    ~header_data:(fun sec orient ->
      if orient = `Horizontal then
        match sec with 0 -> "Name" | 1 -> "Type" | _ -> "Year"
      else
        string_of_int (sec + 1))
    ()
  in
  assert (Object.is_valid table_model);
  TableModel.notify_reset table_model;
  TableModel.notify_data_changed table_model ~top_row:0 ~left_col:0 ~bottom_row:2 ~right_col:2;

  (* 20. Test TableView, HeaderView, ItemSelectionModel *)
  let tv = TableView.create ~parent:win () in
  assert (Object.is_valid tv);
  TableView.set_model tv table_model;
  TableView.set_selection_behavior tv `Select_rows;
  TableView.set_selection_mode tv `Single_selection;
  TableView.set_sorting_enabled tv true;
  TableView.set_alternating_row_colors tv true;
  TableView.resize_columns_to_contents tv;
  TableView.resize_rows_to_contents tv;

  let h_header = TableView.horizontal_header tv in
  assert (Object.is_valid h_header);
  HeaderView.set_stretch_last_section h_header true;
  assert (HeaderView.is_stretch_last_section h_header);
  HeaderView.set_section_resize_mode h_header `Stretch;

  let v_header = TableView.vertical_header tv in
  assert (Object.is_valid v_header);

  let tv_sel = TableView.selection_model tv in
  assert (Object.is_valid tv_sel);
  assert (not (ItemSelectionModel.has_selection tv_sel));
  assert (ItemSelectionModel.selected_rows tv_sel = []);
  ItemSelectionModel.clear_selection tv_sel;

  TableView.on_clicked tv (fun _r _c -> ());
  TableView.on_double_clicked tv (fun _r _c -> ());
  Layout.add_widget layout tv;

  (* 21. Test TreeView *)
  let tree = TreeView.create ~parent:win () in
  assert (Object.is_valid tree);
  TreeView.set_model tree std_model;
  TreeView.expand_all tree;
  TreeView.collapse_all tree;
  let tree_header = TreeView.header tree in
  assert (Object.is_valid tree_header);
  Layout.add_widget layout tree;

  (* 22. Test ListView *)
  let list_v = ListView.create ~parent:win () in
  assert (Object.is_valid list_v);
  ListView.set_model list_v std_model;
  ListView.set_selection_behavior list_v `Select_items;
  Layout.add_widget layout list_v;

  (* 23. Test Timer and Event Loop *)
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
  assert (!paint_count > 0);

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
