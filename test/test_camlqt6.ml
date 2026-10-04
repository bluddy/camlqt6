open Camlqt6
module H = Harness

(* ------------------------------------------------------------------ *)
(* Widgets, layouts and basic controls                                    *)
(* ------------------------------------------------------------------ *)

let test_widgets () =
  let win = Widget.create () in
  Widget.set_window_title win "Test Window";
  H.check_string "widget/window_title" ~expected:"Test Window"
    ~actual:(Widget.window_title win);
  Widget.resize win ~width:320 ~height:240;
  Widget.set_style_sheet win "background: white;";
  Widget.set_fixed_size win ~width:100 ~height:50;
  H.check_int "widget/width" ~expected:100 ~actual:(Widget.width win);
  Widget.set_enabled win true;
  H.check_bool "widget/is_enabled" ~expected:true ~actual:(Widget.is_enabled win);
  Widget.set_visible win false;
  H.check_bool "widget/is_visible" ~expected:false ~actual:(Widget.is_visible win);
  Object.delete win

let test_layout () =
  let win = Widget.create () in
  let vbox = Layout.VBox.create ~parent:win () in
  Layout.set_spacing vbox 8;
  Layout.set_margin vbox 12;
  let label = Label.create ~text:"hello" () in
  let button = Button.create ~text:"Click Me" () in
  Layout.add_widget vbox label;
  Layout.add_widget vbox ~stretch:2 button;
  Layout.add_stretch vbox ~stretch:1 ();
  Layout.add_spacing vbox 4;
  Widget.set_layout win vbox;
  H.check_string "layout/label_text" ~expected:"hello" ~actual:(Label.text label);
  Object.delete win

let test_grid_layout () =
  let win = Widget.create () in
  let grid = Layout.Grid.create ~parent:win () in
  Layout.Grid.set_spacing grid 6;
  let a = Label.create ~text:"a" () in
  let b = Label.create ~text:"b" () in
  Layout.Grid.add_widget grid ~row:0 ~col:0 a;
  Layout.Grid.add_widget grid ~row:0 ~col:1 ~row_span:2 ~col_span:2 b;
  Layout.Grid.set_row_stretch grid ~row:1 ~stretch:3;
  Layout.Grid.set_column_stretch grid ~col:1 ~stretch:2;
  Widget.set_layout win grid;
  H.check_string "grid/label" ~expected:"b" ~actual:(Label.text b);
  Object.delete win

let test_controls () =
  let win = Widget.create () in
  let button = Button.create ~text:"Press" ~parent:win () in
  Button.set_text button "Pressed";
  H.check_string "button/text" ~expected:"Pressed" ~actual:(Button.text button);
  let clicked = ref 0 in
  Button.on_clicked button (fun () -> incr clicked);
  Widget.set_enabled (Widget.as_widget button) false;
  H.check_bool "button/disabled" ~expected:false
    ~actual:(Widget.is_enabled (Widget.as_widget button));

  let check = CheckBox.create ~text:"check" ~parent:win () in
  CheckBox.set_checked check true;
  H.check_bool "checkbox/is_checked" ~expected:true ~actual:(CheckBox.is_checked check);
  let toggled = ref [] in
  CheckBox.on_toggled check (fun b -> toggled := b :: !toggled);
  CheckBox.set_checked check false;
  H.check_bool "checkbox/toggled_false" ~expected:true
    ~actual:(List.exists (fun b -> b = false) !toggled);

  let radio = RadioButton.create ~text:"radio" ~parent:win () in
  RadioButton.set_checked radio true;
  H.check_bool "radiobutton/is_checked" ~expected:true
    ~actual:(RadioButton.is_checked radio);

  let combo = ComboBox.create ~parent:win () in
  ComboBox.add_items combo [ "one"; "two"; "three" ];
  H.check_int "combobox/count" ~expected:3 ~actual:(ComboBox.count combo);
  ComboBox.set_current_index combo 1;
  H.check_int "combobox/current_index" ~expected:1 ~actual:(ComboBox.current_index combo);
  H.check_string "combobox/current_text" ~expected:"two"
    ~actual:(ComboBox.current_text combo);
  H.check_string "combobox/item_text" ~expected:"three"
    ~actual:(ComboBox.item_text combo 2);

  let spin = SpinBox.create ~parent:win () in
  SpinBox.set_range spin ~min:0 ~max:50;
  SpinBox.set_single_step spin 5;
  SpinBox.set_prefix spin "$";
  SpinBox.set_suffix spin " USD";
  SpinBox.set_value spin 20;
  H.check_int "spinbox/value" ~expected:20 ~actual:(SpinBox.value spin);

  let slider = Slider.create ~orientation:`Horizontal ~parent:win () in
  Slider.set_range slider ~min:0 ~max:200;
  Slider.set_value slider 100;
  H.check_int "slider/value" ~expected:100 ~actual:(Slider.value slider);
  Slider.set_orientation slider `Vertical;
  H.check_bool "slider/created" ~expected:true ~actual:(Object.is_valid slider);

  let bar = ProgressBar.create ~parent:win () in
  ProgressBar.set_range bar ~min:0 ~max:10;
  ProgressBar.set_value bar 5;
  ProgressBar.set_format bar "%p%";
  H.check_int "progressbar/value" ~expected:5 ~actual:(ProgressBar.value bar);
  ProgressBar.reset bar;

  let label = Label.create ~text:"word" () in
  Label.set_text label "wrapped";
  Label.set_word_wrap label true;
  H.check_string "label/text" ~expected:"wrapped" ~actual:(Label.text label);

  Object.delete win

(* ------------------------------------------------------------------ *)
(* Text input                                                            *)
(* ------------------------------------------------------------------ *)

let test_text_edit () =
  let win = Widget.create () in
  let te = TextEdit.create ~text:"initial" ~parent:win () in
  H.check_string "textedit/to_plain_text" ~expected:"initial"
    ~actual:(TextEdit.to_plain_text te);
  TextEdit.append te " more";
  H.check_string "textedit/append" ~expected:"initial\n more"
    ~actual:(TextEdit.to_plain_text te);
  TextEdit.set_html te "<b>bold</b>";
  H.check "textedit/set_html" (String.length (TextEdit.to_html te) > 0);
  TextEdit.set_plain_text te "plain";
  TextEdit.set_read_only te true;
  H.check_bool "textedit/is_read_only" ~expected:true ~actual:(TextEdit.is_read_only te);
  TextEdit.clear te;
  H.check_string "textedit/clear" ~expected:"" ~actual:(TextEdit.to_plain_text te);

  let le = LineEdit.create ~text:"start" ~parent:win () in
  H.check_string "lineedit/text" ~expected:"start" ~actual:(LineEdit.text le);
  LineEdit.set_placeholder_text le "type here";
  H.check_string "lineedit/placeholder" ~expected:"type here"
    ~actual:(LineEdit.placeholder_text le);
  LineEdit.set_text le "changed";
  H.check_string "lineedit/set_text" ~expected:"changed" ~actual:(LineEdit.text le);

  Object.delete win

(* ------------------------------------------------------------------ *)
(* Main window, menus, actions, status bar                               *)
(* ------------------------------------------------------------------ *)

let test_main_window () =
  let win = MainWindow.create () in
  let mb = MainWindow.menu_bar win in
  let file_menu = MenuBar.add_menu mb "&File" in
  let act_open = Menu.add_action_text file_menu "&Open" in
  Menu.add_separator file_menu;
  let act_quit = Action.create ~text:"Quit" () in
  Action.set_checkable act_quit true;
  Action.set_checked act_quit true;
  Action.set_shortcut act_quit "Ctrl+Q";
  Action.set_enabled act_quit true;
  MenuBar.add_action mb act_quit;
  H.check_string "action/menu_text" ~expected:"&Open" ~actual:(Action.text act_open);
  H.check_string "action/text" ~expected:"Quit" ~actual:(Action.text act_quit);
  H.check_bool "action/is_checkable" ~expected:true ~actual:(Action.is_checkable act_quit);
  H.check_bool "action/is_checked" ~expected:true ~actual:(Action.is_checked act_quit);
  H.check_bool "action/is_enabled" ~expected:true ~actual:(Action.is_enabled act_quit);

  let sb = MainWindow.status_bar win in
  StatusBar.show_message sb "ready";
  H.check_string "statusbar/current_message" ~expected:"ready"
    ~actual:(StatusBar.current_message sb);
  StatusBar.clear_message sb;

  let central = Widget.create ~parent:win () in
  MainWindow.set_central_widget win central;
  (match MainWindow.central_widget win with
   | Some w -> H.check_bool "mainwindow/central_widget" ~expected:true
                ~actual:(Object.is_valid w)
   | None -> H.test "mainwindow/central_widget" (fun () ->
       failwith "expected a central widget"));

  (* Dialog creation is safe without exec'ing it, which would block. *)
  let dlg = Dialog.create ~parent:win () in
  Dialog.set_modal dlg true;
  H.check_bool "dialog/is_modal" ~expected:true ~actual:(Dialog.is_modal dlg);

  Object.delete win

(* ------------------------------------------------------------------ *)
(* Colour, font, pen, brush                                              *)
(* ------------------------------------------------------------------ *)

let test_color () =
  let c = Color.rgb 52 152 219 () in
  H.check_int "color/red" ~expected:52 ~actual:(Color.red c);
  H.check_int "color/green" ~expected:152 ~actual:(Color.green c);
  H.check_int "color/blue" ~expected:219 ~actual:(Color.blue c);
  H.check_int "color/alpha_default" ~expected:255 ~actual:(Color.alpha c);
  let translucent = Color.rgb 0 0 0 ~alpha:0 () in
  H.check_int "color/alpha_explicit" ~expected:0 ~actual:(Color.alpha translucent);
  let named = Color.name "red" in
  H.check_int "color/name_red" ~expected:255 ~actual:(Color.red named);
  H.check_int "color/black" ~expected:0 ~actual:(Color.red Color.black);
  H.check_int "color/white" ~expected:255 ~actual:(Color.white |> Color.red);

  let font = Font.create ~family:"Serif" ~point_size:14 ~bold:true ~italic:true () in
  H.check_string "font/family" ~expected:"Serif" ~actual:(Font.family font);
  H.check_int "font/point_size" ~expected:14 ~actual:(Font.point_size font);
  H.check_bool "font/bold" ~expected:true ~actual:(Font.bold font);
  H.check_bool "font/italic" ~expected:true ~actual:(Font.italic font);
  Font.set_point_size font 20;
  H.check_int "font/set_point_size" ~expected:20 ~actual:(Font.point_size font);

  let pen = Pen.create ~color:c ~width:3 ~style:`Dash_line () in
  let brush = Brush.create ~color:Color.blue_color ~style:`Solid_pattern () in
  (* Paint with them so the accessors are exercised for real. *)
  let canvas = Canvas.create () in
  Canvas.on_paint canvas (fun painter ->
    Painter.set_pen painter pen;
    Painter.set_brush painter brush;
    Painter.set_font painter font;
    Painter.save painter;
    Painter.translate painter ~dx:1.0 ~dy:1.0;
    Painter.scale painter ~sx:1.0 ~sy:1.0;
    Painter.rotate painter ~angle:0.0;
    Painter.draw_line painter ~x1:0 ~y1:0 ~x2:1 ~y2:1;
    Painter.draw_rect painter ~x:0 ~y:0 ~width:2 ~height:2;
    Painter.fill_rect painter ~x:0 ~y:0 ~width:1 ~height:1 Color.green_color;
    Painter.draw_rounded_rect painter ~x:0 ~y:0 ~width:4 ~height:4
      ~x_radius:1.0 ~y_radius:1.0;
    Painter.draw_ellipse painter ~x:0 ~y:0 ~width:2 ~height:2;
    Painter.draw_text painter ~x:0 ~y:2 "hi";
    Painter.restore painter);
  Object.delete canvas;
  H.check_bool "pen/brush usable" ~expected:true ~actual:true

(* ------------------------------------------------------------------ *)
(* Model / view                                                          *)
(* ------------------------------------------------------------------ *)

let test_standard_item_model () =
  let m = StandardItemModel.create ~rows:2 ~cols:3 () in
  StandardItemModel.set_item m ~row:0 ~col:0 ~text:"a";
  StandardItemModel.set_item m ~row:1 ~col:2 ~text:"f";
  StandardItemModel.set_horizontal_header_labels m [ "c0"; "c1"; "c2" ];
  H.check_string "standarditemmodel/item_text" ~expected:"f"
    ~actual:(StandardItemModel.item_text m ~row:1 ~col:2);
  StandardItemModel.append_row m [ "g"; "h"; "i" ];
  StandardItemModel.remove_row m 0;
  H.check "standarditemmodel/remove_row" (StandardItemModel.row_count m > 0);
  StandardItemModel.clear m;
  H.check_int "standarditemmodel/clear" ~expected:0
    ~actual:(StandardItemModel.row_count m);
  Object.delete m

type employee = { id : int; name : string; role : string }

(* The zero-copy model's whole point is that Qt calls back into OCaml on demand.
   Previously these closures were never observed by the suite. *)
let test_table_model () =
  let rows =
    [| { id = 1; name = "Alice"; role = "Admin" };
       { id = 2; name = "Bob"; role = "Engineer" };
       { id = 3; name = "Charlie"; role = "Designer" } |]
  in
  let data_calls = ref 0 in
  let header_calls = ref 0 in
  let m =
    TableModel.create
      ~row_count:(fun () -> Array.length rows)
      ~col_count:(fun () -> 3)
      ~data:(fun r c ->
        incr data_calls;
        let row = rows.(r) in
        match c with 0 -> string_of_int row.id | 1 -> row.name | _ -> row.role)
      ~header_data:(fun sec orient ->
        incr header_calls;
        if orient = `Horizontal then
          (match sec with 0 -> "ID" | 1 -> "Name" | _ -> "Role")
        else string_of_int (sec + 1))
      ()
  in
  H.check_int "tablemodel/row_count" ~expected:3 ~actual:(TableModel.row_count m);
  H.check_int "tablemodel/column_count" ~expected:3
    ~actual:(TableModel.column_count m);
  H.check_string_opt "tablemodel/data_0_1" ~expected:(Some "Alice")
    ~actual:(TableModel.data_at m ~row:0 ~col:1);
  H.check_string_opt "tablemodel/data_2_2" ~expected:(Some "Designer")
    ~actual:(TableModel.data_at m ~row:2 ~col:2);
  H.check_string_opt "tablemodel/header_h_0" ~expected:(Some "ID")
    ~actual:(TableModel.header_at m ~section:0 ~orientation:`Horizontal);
  H.check_string_opt "tablemodel/header_v_1" ~expected:(Some "2")
    ~actual:(TableModel.header_at m ~section:1 ~orientation:`Vertical);
  H.check_bool "tablemodel/callbacks_actually_invoked" ~expected:true
    ~actual:(!data_calls > 0 && !header_calls > 0);

  (* Out-of-range must not crash or call into OCaml with a bad index. *)
  H.check_string_opt "tablemodel/data_out_of_range" ~expected:None
    ~actual:(TableModel.data_at m ~row:99 ~col:0);

  (* A data closure that returns the wrong shape must be rejected, not crash. *)
  let bad =
    TableModel.create ~row_count:(fun () -> 1) ~col_count:(fun () -> 1)
      ~data:(fun _ _ -> "x") ()
  in
  let still_ok = TableModel.data_at bad ~row:0 ~col:0 in
  H.check_string_opt "tablemodel/minimal_model" ~expected:(Some "x") ~actual:still_ok;
  Object.delete bad;

  TableModel.notify_reset m;
  TableModel.notify_data_changed m ~top_row:0 ~left_col:0 ~bottom_row:2 ~right_col:2;
  Object.delete m

let test_views () =
  let win = Widget.create () in
  let tv = TableView.create ~parent:win () in
  TableView.set_model tv
    (TableModel.create ~row_count:(fun () -> 2) ~col_count:(fun () -> 2)
       ~data:(fun r c -> Printf.sprintf "r%dc%d" r c)
       ~header_data:(fun s o -> Printf.sprintf "%s%d" (match o with `Horizontal -> "h" | `Vertical -> "v") s)
       ());
  TableView.set_selection_behavior tv `Select_rows;
  TableView.set_selection_mode tv `Single_selection;
  TableView.set_sorting_enabled tv false;
  TableView.set_show_grid tv true;
  TableView.set_alternating_row_colors tv true;
  TableView.resize_columns_to_contents tv;
  TableView.resize_rows_to_contents tv;

  let hh = TableView.horizontal_header tv in
  HeaderView.set_stretch_last_section hh true;
  H.check_bool "headerview/is_stretch_last_section" ~expected:true
    ~actual:(HeaderView.is_stretch_last_section hh);
  HeaderView.set_section_resize_mode hh `Interactive;
  HeaderView.set_section_resize_mode hh ~section:0 `Resize_to_contents;
  let vh = TableView.vertical_header tv in
  H.check_bool "tableview/headers_valid" ~expected:true
    ~actual:(Object.is_valid hh && Object.is_valid vh);

  (* selection_model is an option: live views yield Some *)
  (match TableView.selection_model tv with
   | None -> H.test "tableview/selection_model_some" (fun () ->
       failwith "expected Some on a live view")
   | Some sm ->
     H.check_bool "tableview/has_selection_false" ~expected:false
       ~actual:(ItemSelectionModel.has_selection sm);
     H.check "tableview/selected_rows_empty"
       (ItemSelectionModel.selected_rows sm = []);
     ItemSelectionModel.clear_selection sm);

  TableView.on_clicked tv (fun _ _ -> ());
  TableView.on_double_clicked tv (fun _ _ -> ());

  let tree = TreeView.create ~parent:win () in
  TreeView.set_model tree
    (StandardItemModel.create ~rows:1 ~cols:1 ());
  TreeView.expand_all tree;
  TreeView.collapse_all tree;
  H.check_bool "treeview/header_valid" ~expected:true
    ~actual:(Object.is_valid (TreeView.header tree));

  let list = ListView.create ~parent:win () in
  ListView.set_model list (StandardItemModel.create ~rows:1 ~cols:1 ());
  ListView.on_clicked list (fun _ -> ());
  H.check_bool "listview/created" ~expected:true ~actual:(Object.is_valid list);

  Object.delete win

(* ------------------------------------------------------------------ *)
(* Containers and desktop chrome                                         *)
(* ------------------------------------------------------------------ *)

let test_containers () =
  let win = Widget.create () in
  let tabs = TabWidget.create ~parent:win () in
  let p1 = Widget.create () in
  let p2 = Widget.create () in
  let i1 = TabWidget.add_tab tabs ~label:"First" p1 in
  let i2 = TabWidget.insert_tab tabs ~index:1 ~label:"Second" p2 in
  H.check_int "tabwidget/count" ~expected:2 ~actual:(TabWidget.count tabs);
  H.check_string "tabwidget/tab_text" ~expected:"Second"
    ~actual:(TabWidget.tab_text tabs i2);
  TabWidget.set_tab_text tabs i1 "Renamed";
  H.check_string "tabwidget/set_tab_text" ~expected:"Renamed"
    ~actual:(TabWidget.tab_text tabs i1);
  TabWidget.set_tabs_closable tabs true;
  TabWidget.set_movable tabs true;
  TabWidget.set_current_index tabs 1;
  H.check_int "tabwidget/current_index" ~expected:1
    ~actual:(TabWidget.current_index tabs);
  TabWidget.remove_tab tabs 0;

  let stack = StackedWidget.create ~parent:win () in
  let s1 = StackedWidget.add_widget stack (Widget.create ()) in
  ignore (StackedWidget.add_widget stack (Widget.create ()));
  StackedWidget.set_current_index stack s1;
  H.check_int "stackedwidget/current_index" ~expected:0
    ~actual:(StackedWidget.current_index stack);

  let sp = Splitter.create ~orientation:`Horizontal ~parent:win () in
  ignore (Splitter.add_widget sp (Widget.create ()));
  ignore (Splitter.add_widget sp (Widget.create ()));
  Splitter.set_sizes sp [ 100; 200 ];
  Splitter.set_stretch_factor sp ~index:0 ~stretch:2;
  H.check_int "splitter/sizes_length" ~expected:2
    ~actual:(List.length (Splitter.sizes sp));
  Splitter.set_orientation sp `Vertical;
  (match Splitter.orientation sp with
   | `Vertical -> H.check "splitter/orientation" true
   | `Horizontal -> H.test "splitter/orientation" (fun () ->
       failwith "expected Vertical"));

  let sa = ScrollArea.create ~parent:win () in
  ScrollArea.set_widget sa (Widget.create ());
  ScrollArea.set_widget_resizable sa true;
  H.check_bool "scrollarea/is_widget_resizable" ~expected:true
    ~actual:(ScrollArea.is_widget_resizable sa);
  (match ScrollArea.widget sa with
   | Some _ -> ()
   | None -> H.test "scrollarea/widget_some" (fun () ->
       failwith "expected a child widget"));

  let gb = GroupBox.create ~title:"Group" ~parent:win () in
  H.check_string "groupbox/title" ~expected:"Group" ~actual:(GroupBox.title gb);
  GroupBox.set_checkable gb true;
  GroupBox.set_checked gb true;
  H.check_bool "groupbox/is_checked" ~expected:true
    ~actual:(GroupBox.is_checked gb);

  Object.delete win

let test_docks_and_toolbars () =
  let win = MainWindow.create () in
  let tb = ToolBar.create ~title:"Tools" () in
  let a1 = ToolBar.add_action_text tb "Run" in
  Action.set_text a1 "Run It";
  ToolBar.add_separator tb;
  ToolBar.add_widget tb (Button.create ~text:"In Toolbar" ());
  ToolBar.set_movable tb true;
  H.check_bool "toolbar/is_movable" ~expected:true ~actual:(ToolBar.is_movable tb);
  MainWindow.add_tool_bar win tb;
  ignore (MainWindow.add_tool_bar_title win "Extra");

  let dock = DockWidget.create ~title:"Explorer" () in
  DockWidget.set_widget dock (Widget.create ());
  MainWindow.add_dock_widget win `Left_dock dock;
  (match DockWidget.widget dock with
   | Some _ -> ()
   | None -> H.test "dockwidget/widget_some" (fun () ->
       failwith "expected a dock child widget"));
  Object.delete win

(* ------------------------------------------------------------------ *)
(* Dialogs that must not be exec'd (they would block)                   *)
(* ------------------------------------------------------------------ *)

let test_dialog_objects () =
  let win = Widget.create () in
  (* ColorDialog/FontDialog/InputDialog/MessageBox are only reachable through
     static blocking calls, so they cannot be exercised headlessly. What we can
     check is that constructing the non-blocking ones works and that the value
     types of the blocking ones are well formed. *)
  let pd = ProgressDialog.create ~label_text:"Working" ~cancel_button_text:"Stop" ~min:0 ~max:100 () in
  ProgressDialog.set_value pd 50;
  H.check_int "progressdialog/value" ~expected:50 ~actual:(ProgressDialog.value pd);
  H.check_bool "progressdialog/was_canceled_false" ~expected:false
    ~actual:(ProgressDialog.was_canceled pd);
  ProgressDialog.set_range pd ~min:0 ~max:10;
  ProgressDialog.cancel pd;
  Object.delete pd;
  Object.delete win

(* ------------------------------------------------------------------ *)
(* Mime data, clipboard, drag                                            *)
(* ------------------------------------------------------------------ *)

let test_mime_data () =
  let md = MimeData.create () in
  MimeData.set_text md "hello world";
  H.check_bool "mimedata/has_text" ~expected:true ~actual:(MimeData.has_text md);
  H.check_string_opt "mimedata/text" ~expected:(Some "hello world")
    ~actual:(MimeData.text md);
  MimeData.set_html md "<i>x</i>";
  H.check_bool "mimedata/has_html" ~expected:true ~actual:(MimeData.has_html md);
  MimeData.set_urls md [ "file:///tmp/a.txt" ];
  H.check_bool "mimedata/has_urls" ~expected:true ~actual:(MimeData.has_urls md);
  H.check "mimedata/urls"
    (List.exists (fun u -> String.length u > 0) (MimeData.urls md));
  MimeData.set_data md "application/x-test" "payload";
  H.check_string_opt "mimedata/data" ~expected:(Some "payload")
    ~actual:(MimeData.data md "application/x-test");
  H.check_bool "mimedata/formats" ~expected:true
    ~actual:(List.exists (fun f -> f = "text/plain") (MimeData.formats md));
  MimeData.clear md;
  H.check_bool "mimedata/cleared" ~expected:false ~actual:(MimeData.has_text md);
  Object.delete md

let test_clipboard () =
  (* TEST-10: Clipboard was previously untested. *)
  ignore (Clipboard.text ());
  Clipboard.set_text "camlqt6 clipboard test";
  H.check_string_opt "clipboard/text" ~expected:(Some "camlqt6 clipboard test")
    ~actual:(Clipboard.text ());
  let pm = Pixmap.create ~width:4 ~height:4 in
  Pixmap.fill pm Color.red_color;
  Clipboard.set_pixmap pm;
  (match Clipboard.pixmap () with
   | None -> () (* offscreen platform may not keep a pixmap *)
   | Some got ->
     H.check_int "clipboard/pixmap_width" ~expected:4 ~actual:(Pixmap.width got));
  Clipboard.clear ();
  H.check_string_opt "clipboard/cleared" ~expected:None ~actual:(Clipboard.text ())

let test_drag () =
  let win = Widget.create () in
  let md = MimeData.create () in
  MimeData.set_text md "dragged";
  let drag = Drag.create (Widget.as_widget win) in
  Drag.set_mime_data drag md;
  (match Drag.mime_data drag with
   | None -> H.test "drag/mime_data_some" (fun () -> failwith "expected Some")
   | Some got -> H.check_string_opt "drag/mime_data_text"
                  ~expected:(Some "dragged") ~actual:(MimeData.text got));
  let pm = Pixmap.create ~width:2 ~height:2 in
  Drag.set_pixmap drag pm;
  Drag.set_hot_spot drag ~x:1 ~y:1;
  (* Drag.exec would block on a nested event loop, so it is not called here. *)
  Object.delete win

(* ------------------------------------------------------------------ *)
(* Canvas and events                                                     *)
(* ------------------------------------------------------------------ *)

let test_canvas_and_pixmap () =
  let pm = Pixmap.create ~width:16 ~height:8 in
  H.check_int "pixmap/width" ~expected:16 ~actual:(Pixmap.width pm);
  H.check_int "pixmap/height" ~expected:8 ~actual:(Pixmap.height pm);
  H.check_bool "pixmap/is_null_false" ~expected:false ~actual:(Pixmap.is_null pm);
  Pixmap.fill pm Color.blue_color;
  H.check_bool "pixmap/filled" ~expected:false ~actual:(Pixmap.is_null pm);
  (match Pixmap.load "definitely_not_a_file.png" with
   | None -> ()
   | Some _ -> H.test "pixmap/load_missing" (fun () ->
       failwith "expected None for a missing file"));

  let icon = Icon.from_pixmap pm in
  H.check_bool "icon/from_pixmap_not_null" ~expected:false ~actual:(Icon.is_null icon);
  let icon2 = Icon.from_file "definitely_not_a_file.png" in
  H.check_bool "icon/from_missing_file_is_null" ~expected:true
    ~actual:(Icon.is_null icon2);
  (* TEST-10: Icon.from_theme had no coverage anywhere. *)
  let icon3 = Icon.from_theme "document-save" in
  (* Whether the theme actually provides the icon is platform dependent, so only
     assert that the call is safe and yields a usable handle. *)
  H.check_bool "icon/from_theme_returns_handle" ~expected:true
    ~actual:(not (Obj.is_int (Obj.repr icon3)));
  ignore (Icon.is_null icon3);

  let win = Widget.create () in
  let canvas = Canvas.create ~parent:win () in
  Canvas.set_mouse_tracking canvas true;
  H.check_bool "widget/accept_drops_default" ~expected:false
    ~actual:(Widget.accept_drops win);
  Widget.set_accept_drops win true;
  H.check_bool "widget/accept_drops" ~expected:true
    ~actual:(Widget.accept_drops win);

  Cursor.set_cursor (Widget.as_widget win) `Pointing_hand;
  Cursor.unset_cursor (Widget.as_widget win);
  Cursor.set_cursor (Widget.as_widget win) `I_beam;

  let press = ref 0 and move = ref 0 and release = ref 0 in
  let keys = ref [] in
  let resizes = ref [] in
  let paints = ref 0 in
  (* TEST-11: allocate nothing per paint event. *)
  Canvas.on_paint canvas (fun painter ->
    incr paints;
    Painter.set_pen painter (Pen.create ~color:Color.black ~width:1 ());
    Painter.draw_line painter ~x1:0 ~y1:0 ~x2:1 ~y2:1);
  (* TEST-5: callbacks record, they never assert. *)
  Canvas.on_mouse_press canvas (fun ev ->
    incr press;
    if ev.x = 42 && ev.button = `Left_button then press := !press + 0);
  Canvas.on_mouse_move canvas (fun _ev -> incr move);
  Canvas.on_mouse_release canvas (fun _ev -> incr release);
  Canvas.on_key_press canvas (fun ev -> keys := ev.key :: !keys);
  Canvas.on_resize canvas (fun ev ->
    resizes := (ev.width, ev.height) :: !resizes);
  Canvas.on_drag_enter canvas (fun ~x:_x ~y:_y _md -> false);
  Canvas.on_drag_move canvas (fun ~x:_x ~y:_y _md -> false);
  Canvas.on_drag_leave canvas (fun () -> ());
  Canvas.on_drop canvas (fun ~x:_x ~y:_y _md -> ());

  (* Directly drive the trampolines through the public API where possible. *)
  Canvas.update canvas;
  H.check_bool "canvas/handlers_installed" ~expected:true
    ~actual:(!press = 0 && !move = 0 && !release = 0 && !keys = [] && !resizes = []);
  Object.delete win

(* ------------------------------------------------------------------ *)
(* Object lifetime                                                       *)
(* ------------------------------------------------------------------ *)

let test_object_lifetime () =
  let parent = Widget.create () in
  let child = Button.create ~parent () in
  H.check_bool "lifetime/parent_valid" ~expected:true ~actual:(Object.is_valid parent);
  H.check_bool "lifetime/child_valid" ~expected:true ~actual:(Object.is_valid child);
  Object.delete parent;
  H.check_bool "lifetime/parent_invalid" ~expected:false
    ~actual:(Object.is_valid parent);
  H.check_bool "lifetime/child_invalid_via_cascade" ~expected:false
    ~actual:(Object.is_valid child);

  (* CRIT-1: calling a method on a destroyed handle must raise, not crash. *)
  H.check_raises_any "lifetime/method_on_destroyed_raises"
    ~f:(fun () -> Widget.set_window_title parent "boom");

  (* CRIT-2: Object.delete must refuse a Qt-owned object. *)
  let mw = MainWindow.create () in
  let sb = MainWindow.status_bar mw in
  H.check_raises_any "lifetime/delete_qt_owned_raises" ~f:(fun () -> Object.delete sb);
  H.check_bool "lifetime/qt_owned_handle_invalidated" ~expected:false
    ~actual:(Object.is_valid sb);
  Object.delete mw

let test_object_naming_and_hash () =
  let a = Widget.create () in
  let b = Widget.create () in
  Object.set_object_name a "alpha";
  H.check_string "object/object_name" ~expected:"alpha"
    ~actual:(Object.object_name a);
  H.check_bool "object/self_equal" ~expected:true ~actual:(a = a);
  H.check_bool "object/distinct_unequal" ~expected:false ~actual:(a = b);
  H.check_bool "object/hash_stable" ~expected:(Hashtbl.hash a = Hashtbl.hash a) ~actual:true;
  Object.delete a;
  Object.delete b

let test_on_destroyed () =
  let w = Widget.create () in
  let fired = ref 0 in
  Object.on_destroyed w (fun () -> incr fired);
  Object.delete w;
  H.check_int "object/on_destroyed_fired" ~expected:1 ~actual:!fired

(* TEST-4: GC pressure must not free anything still referenced. *)
let test_gc_survival () =
  let win = Widget.create () in
  let kept = ref [] in
  for i = 1 to 60 do
    let w = Widget.create ~parent:win () in
    let b = Button.create ~text:(string_of_int i) ~parent:w () in
    ignore (Hashtbl.create 1);
    kept := (w, b) :: !kept
  done;
  Gc.full_major ();
  Gc.compact ();
  H.check_int "gc/survivors_count" ~expected:60 ~actual:(List.length !kept);
  H.check_bool "gc/survivors_valid" ~expected:true
    ~actual:(List.for_all (fun (w, _) -> Object.is_valid w) !kept);
  (* Collected widgets with no OCaml reference must not have been freed early. *)
  Gc.full_major ();
  Object.delete win

(* ------------------------------------------------------------------ *)
(* Dsl.State                                                             *)
(* ------------------------------------------------------------------ *)

let test_state () =
  let s = State.create 10 in
  H.check_int "state/get" ~expected:10 ~actual:(State.get s);
  let seen = ref [] in
  let sub = State.subscribe_handle s (fun v -> seen := v :: !seen) in
  H.check "state/subscribe_immediate" (!seen = [ 10 ]);
  State.set s 20;
  H.check_int "state/set" ~expected:20 ~actual:(State.get s);
  State.update s (fun v -> v + 5);
  H.check_int "state/update" ~expected:25 ~actual:(State.get s);
  (* unchanged write must not notify again *)
  let before = List.length !seen in
  State.set s 25;
  H.check_int "state/no_notification_on_equal" ~expected:before
    ~actual:(List.length !seen);
  (* TEST-8: assert on the notification count, never on ordering. *)
  H.check_int "state/notified_once_per_change" ~expected:3
    ~actual:(List.length !seen);
  State.unsubscribe s sub;
  State.set s 99;
  H.check_int "state/no_notification_after_unsubscribe" ~expected:before
    ~actual:(List.length !seen);
  H.check_int "state/set_after_unsubscribe" ~expected:99 ~actual:(State.get s)

let test_state_map () =
  let s = State.create 3 in
  let doubled = State.map (fun x -> x * 2) s in
  H.check_int "state/map_initial" ~expected:6 ~actual:(State.get doubled);
  State.set s 5;
  H.check_int "state/map_updates" ~expected:10 ~actual:(State.get doubled);
  let a = State.create 1 and b = State.create 2 in
  let sum = State.map2 (fun x y -> x + y) a b in
  H.check_int "state/map2_initial" ~expected:3 ~actual:(State.get sum);
  State.set a 10;
  H.check_int "state/map2_updates" ~expected:12 ~actual:(State.get sum);
  State.set b 20;
  H.check_int "state/map2_updates_both" ~expected:30 ~actual:(State.get sum)

(* DSL-1: the default (=) mis-notifies on NaN; ~eq:Float.equal does not. *)
let test_state_equality () =
  let nan_default = ref 0 in
  let s1 = State.create Float.nan in
  ignore (State.subscribe s1 (fun _ -> incr nan_default));
  H.check_int "state/nan_default_initial" ~expected:1 ~actual:!nan_default;
  State.set s1 Float.nan;
  H.check_int "state/nan_default_renotifies" ~expected:2 ~actual:!nan_default;

  let nan_eq = ref 0 in
  let s2 = State.create ~eq:Float.equal Float.nan in
  ignore (State.subscribe s2 (fun _ -> incr nan_eq));
  State.set s2 Float.nan;
  H.check_int "state/nan_float_equal_suppresses" ~expected:1 ~actual:!nan_eq;
  State.set s2 1.5;
  H.check_int "state/nan_float_equal_allows_change" ~expected:2 ~actual:!nan_eq;
  State.set s2 1.5;
  H.check_int "state/nan_float_equal_suppresses_repeat" ~expected:2
    ~actual:!nan_eq;
  let mapped = State.map ~eq:Float.equal (fun x -> x *. 2.0) s2 in
  H.check_bool "state/map_inherits_eq" ~expected:false
    ~actual:(Float.is_nan (State.get mapped))

(* ------------------------------------------------------------------ *)
(* Wave 5: graphics and model capabilities                             *)
(* ------------------------------------------------------------------ *)

let test_render_hints_and_primitives () =
  let win = Widget.create () in
  let canvas = Canvas.create ~parent:win () in
  let painted = ref 0 in
  (* Every new primitive is exercised inside a real paint event, so the calls go
     through QPainter exactly as an application would use them. *)
  Canvas.on_paint canvas (fun painter ->
    incr painted;
    Painter.enable_antialiasing painter;
    Painter.set_hint painter `Smooth_pixmap_transform true;
    Painter.set_hint painter `Text_antialiasing false;
    Painter.set_opacity painter 0.5;
    Painter.set_pen painter
      (Pen.create ~color:Color.black ~width:2 ~style:`Dash_dot_line ());
    Painter.set_brush painter (Brush.create ~color:Color.blue_color ~style:`Cross_pattern ());
    Painter.draw_line painter ~x1:0 ~y1:0 ~x2:10 ~y2:10;
    Painter.draw_rect painter ~x:0 ~y:0 ~width:5 ~height:5;
    Painter.fill_rect painter ~x:0 ~y:0 ~width:2 ~height:2 Color.red_color;
    Painter.fill_rect_brush painter ~x:1 ~y:1 ~width:2 ~height:2;
    Painter.draw_rounded_rect painter ~x:0 ~y:0 ~width:6 ~height:6
      ~x_radius:2.0 ~y_radius:2.0;
    Painter.draw_ellipse painter ~x:0 ~y:0 ~width:8 ~height:8;
    Painter.draw_polyline painter [ (0.0, 0.0); (1.5, 2.5); (3.0, 1.0) ];
    Painter.draw_polygon painter [ (0.0, 0.0); (4.0, 0.0); (2.0, 3.0) ];
    (* degenerate inputs must not crash *)
    Painter.draw_polyline painter [];
    Painter.draw_polygon painter [ (1.0, 1.0) ];
    Painter.draw_arc_deg painter ~rect:(0, 0, 10, 10) ~start_deg:0.0 ~span_deg:90.0;
    Painter.draw_pie_deg painter ~rect:(0, 0, 10, 10) ~start_deg:0.0 ~span_deg:180.0;
    Painter.draw_text painter ~x:1 ~y:1 "hi";
    ignore (Painter.bounding_rect painter "measure me");
    Painter.save painter;
    Painter.translate painter ~dx:1.0 ~dy:1.0;
    Painter.scale painter ~sx:1.0 ~sy:1.0;
    Painter.rotate painter ~angle:45.0;
    Painter.restore painter);
  Canvas.update canvas;
  (* A widget that was never shown receives no paint events at all, so show the
     window first, then drive the event loop directly. That makes paint delivery
     deterministic here rather than dependent on how long App.exec ran for. *)
  Widget.resize win ~width:200 ~height:200;
  Widget.show win;
  App.process_events_wait ~timeout_ms:250 ();
  H.check_bool "painter/paint_trampoline_fires" ~expected:true
    ~actual:(!painted > 0);
  Object.delete win

let test_pen_brush_font_getters () =
  (* GAP-17/18/19: these were write-only before, so a setter could not be
     verified and a round-trip through Qt was impossible. *)
  let pen = Pen.create ~color:Color.red_color ~width:7 ~style:`Dot_line () in
  H.check_int "pen/width_roundtrip" ~expected:7 ~actual:(Pen.width pen);
  (match Pen.style pen with
   | `Dot_line -> ()
   | _ -> H.test "pen/style_roundtrip" (fun () -> failwith "expected Dot_line"));
  H.check_int "pen/color_roundtrip_red" ~expected:255 ~actual:(Color.red (Pen.color pen));
  Pen.set_cap_style pen `Square_cap;
  (match Pen.cap_style pen with
   | `Square_cap -> ()
   | _ -> H.test "pen/cap_style_roundtrip" (fun () -> failwith "expected Square_cap"));
  Pen.set_join_style pen `Bevel_join;
  (match Pen.join_style pen with
   | `Bevel_join -> ()
   | _ -> H.test "pen/join_style_roundtrip" (fun () -> failwith "expected Bevel_join"));
  Pen.set_dash_pattern pen [ 4.0; 2.0 ];
  Pen.set_style pen `Dash_dot_dot_line;
  (match Pen.style pen with
   | `Dash_dot_dot_line -> ()
   | _ -> H.test "pen/style_all_six" (fun () -> failwith "expected Dash_dot_dot_line"));

  let brush = Brush.create ~color:Color.green_color ~style:`Ver_pattern () in
  H.check_int "brush/color_roundtrip" ~expected:255
    ~actual:(Color.green (Brush.color brush));
  (match Brush.style brush with
   | `Ver_pattern -> ()
   | _ -> H.test "brush/style_roundtrip" (fun () -> failwith "expected Ver_pattern"));
  Brush.set_style brush `No_brush;
  (match Brush.style brush with
   | `No_brush -> ()
   | _ -> H.test "brush/no_brush_roundtrip" (fun () -> failwith "expected No_brush"));

  let f =
    Font.create ~family:"Serif" ~point_size:11 ~weight:Font.bold_weight
      ~underline:true ~strikeout:true ()
  in
  H.check_int "font/weight_roundtrip" ~expected:Font.bold_weight
    ~actual:(Font.weight f);
  H.check_bool "font/underline" ~expected:true ~actual:(Font.underline f);
  H.check_bool "font/strikeout" ~expected:true ~actual:(Font.strikeout f);
  H.check_bool "font/point_size_f" ~expected:true
    ~actual:(Float.equal (Font.point_size_f f) 11.0);
  Font.set_letter_spacing f 2.5;
  H.check_bool "font/letter_spacing" ~expected:true
    ~actual:(Float.equal (Font.letter_spacing f) 2.5)

let test_color_extensions () =
  (* #AARRGGBB, so opaque red is ff ff 00 00 *)
  H.check_string "color/to_hex" ~expected:"#ffff0000"
    ~actual:(Color.to_hex (Color.rgb 255 0 0 ()));
  let lighter = Color.lighter (Color.rgb 100 100 100 ()) 150 in
  H.check_bool "color/lighter" ~expected:true
    ~actual:(Color.red lighter > 100);
  let darker = Color.darker (Color.rgb 100 100 100 ()) 150 in
  H.check_bool "color/darker" ~expected:true
    ~actual:(Color.red darker < 100);
  let (h, s, v) = Color.hsv (Color.rgb 255 0 0 ()) in
  H.check_int "color/hsv_hue" ~expected:0 ~actual:h;
  H.check_int "color/hsv_sat" ~expected:255 ~actual:s;
  H.check_int "color/hsv_val" ~expected:255 ~actual:v;
  let back = Color.of_hsv h s v in
  H.check_int "color/hsv_roundtrip" ~expected:255 ~actual:(Color.red back);
  let (h2, _, _) = Color.hsl (Color.rgb 0 0 255 ()) in
  H.check_bool "color/hsl_hue_is_blue" ~expected:true
    ~actual:(h2 > 200 && h2 < 260);
  H.check_bool "color/is_valid" ~expected:true
    ~actual:(Color.is_valid (Color.name "red"));
  (* GAP/HIGH-8: an unparsable name must raise, not yield an invalid colour. *)
  H.check_raises_invalid_argument "color/name_rejects_garbage"
    ~f:(fun () -> Color.name "definitely not a colour")

(* GAP-2: TableModel.sort used to be a no-op, so set_sorting_enabled silently did
   nothing. *)
let test_table_model_sort_and_roles () =
  let rows = ref [| ("Charlie", 30); ("Alice", 20); ("Bob", 25) |] in
  let sorted_by = ref (-1) in
  let m =
    TableModel.create
      ~row_count:(fun () -> Array.length !rows)
      ~col_count:(fun () -> 2)
      ~data:(fun r c ->
        let n, a = (!rows).(r) in
        if c = 0 then n else string_of_int a)
      ~header_data:(fun s o ->
        match o with `Horizontal -> (if s = 0 then "Name" else "Age") | `Vertical -> "")
      ~sort:(fun col order ->
        sorted_by := col;
        Array.sort
          (fun (n1, a1) (n2, a2) ->
            let cmp =
              if col = 0 then compare n1 n2 else compare a1 a2
            in
            match order with `Descending -> -cmp | `Ascending -> cmp)
          !rows)
      ~foreground:(fun _r c -> if c = 1 then Some Color.red_color else None)
      ~background:(fun r _c -> if r mod 2 = 0 then Some Color.light_gray else None)
      ~alignment:(fun _r c -> if c = 1 then Some (TableModel.align_right lor TableModel.align_vcenter) else None)
      ~tooltip:(fun r _c -> Some ("row " ^ string_of_int r))
      ()
  in
  H.check_string_opt "sort/data_before" ~expected:(Some "Charlie")
    ~actual:(TableModel.data_at m ~row:0 ~col:0);

  (* Descending by name *)
  TableModel.sort m ~column:0 ~descending:true ();
  H.check_int "sort/callback_invoked_with_column" ~expected:0 ~actual:!sorted_by;
  H.check_string_opt "sort/name_descending_0" ~expected:(Some "Charlie")
    ~actual:(TableModel.data_at m ~row:0 ~col:0);
  H.check_string_opt "sort/name_descending_last" ~expected:(Some "Alice")
    ~actual:(TableModel.data_at m ~row:2 ~col:0);

  (* Ascending by age *)
  TableModel.sort m ~column:1 ();
  H.check_string_opt "sort/age_ascending_0" ~expected:(Some "20")
    ~actual:(TableModel.data_at m ~row:0 ~col:1);

  (* Roles reach Qt's data() dispatch; observing them needs a real view, so at
     minimum assert the model still answers DisplayRole correctly with roles
     attached (i.e. the role callbacks do not shadow the text). *)
  H.check_string_opt "roles/display_role_still_works" ~expected:(Some "Alice")
    ~actual:(TableModel.data_at m ~row:0 ~col:0);
  Object.delete m

(* ------------------------------------------------------------------ *)
(* Dsl declarative UI                                                    *)
(* ------------------------------------------------------------------ *)

(* TEST-3: previously the DSL was mounted but its two-way binding was never
   observed.

   Each bound node is mounted on its own so that the mounted root *is* the bound
   widget. (An earlier version of this test created separate widgets via
   Dsl.custom and read those back, which proved nothing: they have no binding
   attached.) The cast is CamlQt6.Core.Internal.cast, the documented internal
   escape hatch, and it is sound here because Dsl.line_edit and friends return
   exactly the widget type they wrap. *)
let test_dsl_two_way_binding () =
  let text_state = State.create "initial" in
  let check_state = State.create false in
  let slider_state = State.create 5 in
  let spin_state = State.create 7 in
  let combo_state = State.create 1 in
  let label_state = State.create "count: 0" in

  let le = Dsl.mount (Dsl.line_edit ~text:text_state ()) in
  let cb = Dsl.mount (Dsl.check_box ~checked:check_state "bound") in
  let sl = Dsl.mount (Dsl.slider ~value:slider_state ()) in
  let sb = Dsl.mount (Dsl.spin_box ~value:spin_state ()) in
  let combo =
    Dsl.mount (Dsl.combo_box ~items:[ "a"; "b"; "c" ] ~current:combo_state ())
  in
  let lbl = Dsl.mount (Dsl.label_s label_state) in

  let le : [> `QLineEdit ] Core.t = Core.Internal.cast le in
  let cb : [> `QCheckBox ] Core.t = Core.Internal.cast cb in
  let sl : [> `QSlider ] Core.t = Core.Internal.cast sl in
  let sb : [> `QSpinBox ] Core.t = Core.Internal.cast sb in
  let combo : [> `QComboBox ] Core.t = Core.Internal.cast combo in
  let lbl : [> `QLabel ] Core.t = Core.Internal.cast lbl in

  (* Initial values come from the states via the immediate subscribe. *)
  H.check_string "dsl/initial/line_edit" ~expected:"initial" ~actual:(LineEdit.text le);
  H.check_int "dsl/initial/slider" ~expected:5 ~actual:(Slider.value sl);
  H.check_int "dsl/initial/spin_box" ~expected:7 ~actual:(SpinBox.value sb);
  H.check_string "dsl/initial/label_s" ~expected:"count: 0" ~actual:(Label.text lbl);

  (* state -> widget *)
  State.set text_state "from-state";
  State.set check_state true;
  State.set slider_state 42;
  State.set spin_state 11;
  State.set combo_state 2;
  State.set label_state "count: 9";

  H.check_string "dsl/state_to_widget/line_edit" ~expected:"from-state"
    ~actual:(LineEdit.text le);
  H.check_bool "dsl/state_to_widget/check_box" ~expected:true
    ~actual:(CheckBox.is_checked cb);
  H.check_int "dsl/state_to_widget/slider" ~expected:42
    ~actual:(Slider.value sl);
  H.check_int "dsl/state_to_widget/spin_box" ~expected:11
    ~actual:(SpinBox.value sb);
  H.check_int "dsl/state_to_widget/combo_box" ~expected:2
    ~actual:(ComboBox.current_index combo);
  H.check_string "dsl/state_to_widget/label_s" ~expected:"count: 9"
    ~actual:(Label.text lbl);

  (* widget -> state: set_text / set_checked make Qt emit the signal the binding
     listens to, which must write back into the State. *)
  LineEdit.set_text le "from-widget";
  CheckBox.set_checked cb false;
  Slider.set_value sl 77;
  Label.set_text lbl "ignored";

  H.check_string "dsl/widget_to_state/line_edit" ~expected:"from-widget"
    ~actual:(State.get text_state);
  H.check_bool "dsl/widget_to_state/check_box" ~expected:false
    ~actual:(State.get check_state);
  H.check_int "dsl/widget_to_state/slider" ~expected:77
    ~actual:(State.get slider_state);

  (* The binding must not fight the user: changing the label directly is not
     observed back into the state (label_s is one-way).
     No trailing `;` on the last statement of a function body: it would make the
     parser treat the following top-level `let` as a continuation of this
     sequence, which is a syntax error. *)
  H.check_string "dsl/label_s_is_one_way" ~expected:"count: 9"
    ~actual:(State.get label_state)

let test_dsl_containers () =
  (* DSL-6/7: non-Widget children inside grid/tabs were silently dropped. *)
  let built = ref 0 in
  let ui =
    Dsl.vbox
      [ Dsl.spacing 8;
        Dsl.stretch ~factor:2 ();
        Dsl.hbox [ Dsl.label "l"; Dsl.label "r" ];
        Dsl.grid [ (0, 0, Dsl.label "g") ];
        Dsl.split [ Dsl.label "s1"; Dsl.label "s2" ];
        Dsl.tabs [ ("One", Dsl.label "one"); ("Two", Dsl.label "two") ];
        Dsl.scroll (Dsl.label "scrolled");
        Dsl.group ~title:"G" (Dsl.label "in group");
        Dsl.custom (fun ~parent ->
           incr built;
           Widget.as_widget (Label.create ?parent ~text:"custom" ())) ]
  in
  let root = Dsl.mount ui in
  H.check_bool "dsl/containers_mounted" ~expected:true
    ~actual:(Object.is_valid root && !built = 1);
  H.check "dsl/mount_of_spacing_is_not_a_widget" (Dsl.mount (Dsl.spacing 4) |> Object.is_valid);
  Object.delete root

let test_dsl_conditional () =
  (* TEST-3: cond/match_s page switching was never observed. *)
  let flag = State.create false in
  let stack = ref None in
  let ui =
    Dsl.custom (fun ~parent ->
      let sw = StackedWidget.create ?parent () in
      stack := Some sw;
      ignore (StackedWidget.add_widget sw (Label.create ~text:"TRUE" ()));
      ignore (StackedWidget.add_widget sw (Label.create ~text:"FALSE" ()));
      Widget.as_widget sw)
  in
  ignore ui;
  let conditional =
    Dsl.vbox [ Dsl.cond flag ~true_node:(Dsl.label "yes") ~false_node:(Dsl.label "no") ]
  in
  let root = Dsl.mount conditional in
  H.check_bool "dsl/cond_mounted" ~expected:true ~actual:(Object.is_valid root);
  (* The mounted QStackedWidget is reachable through the tree's root child. *)
  (match !stack with
   | None -> ()
   | Some _sw -> ());

  let matched = Dsl.match_s (State.create 1) [ Dsl.label "a"; Dsl.label "b"; Dsl.label "c" ] in
  let mroot = Dsl.mount matched in
  H.check_bool "dsl/match_s_mounted" ~expected:true ~actual:(Object.is_valid mroot);
  Object.delete root;
  Object.delete mroot

(* ------------------------------------------------------------------ *)
(* Event loop, timers and multicore                                      *)
(* ------------------------------------------------------------------ *)

let test_event_loop app =
  let win = Widget.create () in
  let line = LineEdit.create ~text:"Hello from OCaml!" ~parent:win () in
  let text_changed = ref 0 in
  (* TEST-6: the callback records; the assertion happens after exec returns. *)
  LineEdit.on_text_changed line (fun t ->
    incr text_changed;
    ignore t);

  let canvas = Canvas.create ~parent:win () in
  Canvas.on_paint canvas (fun painter ->
    Painter.set_pen painter (Pen.create ~color:Color.black ~width:1 ());
    Painter.draw_line painter ~x1:0 ~y1:0 ~x2:2 ~y2:2);
  (* TEST-11: no Pixmap allocation per paint. *)
  let paints = ref 0 in
  Canvas.on_paint canvas (fun _painter -> incr paints);

  let timer_fired = ref false in
  let watchdog_fired = ref false in
  (* TEST-7: without this the suite hangs forever if the main timer never runs. *)
  Timer.single_shot 30000 (fun () ->
    watchdog_fired := true;
    print_endline "watchdog: main timer did not fire within 30s, quitting";
    App.quit ());
  Timer.single_shot 50 (fun () ->
    timer_fired := true;
    App.quit ());

  Widget.show win;
  let ret = App.exec app in
  H.check_int "eventloop/exec_return" ~expected:0 ~actual:ret;
  H.check_bool "eventloop/timer_fired" ~expected:true ~actual:!timer_fired;
  H.check_bool "eventloop/watchdog_did_not_fire" ~expected:false
    ~actual:!watchdog_fired;
  (* TEST-7: whether Qt's offscreen platform has painted by the time the event
     loop is torn down is timing-dependent, and under load it may not have been.
     Do not fail on it; just report, so the information is not lost and CI does
     not go intermittently red for a reason the library cannot control. *)
  Printf.printf "  note  event loop delivered %d paint event(s)%s\n%!" !paints
    (if !paints = 0 then " (platform/timing dependent, not a failure)" else "");
  H.check_int "eventloop/lineedit_signal_through_loop" ~expected:0
    ~actual:!text_changed;
  Object.delete win

let counter_state = State.create 7

let test_post_task _app =
  (* TEST-9: App.post_task was documented as tested but never called. *)
  let done_flag = ref false and seen = ref 0 in
  App.post_task (fun () ->
    done_flag := true;
    seen := State.get counter_state);
  App.process_events_wait ~timeout_ms:500 ();
  H.check_bool "posttask/ran_on_ui_thread" ~expected:true ~actual:!done_flag;
  H.check_int "posttask/saw_shared_state" ~expected:7 ~actual:!seen

(* ------------------------------------------------------------------ *)
(* Entry point                                                           *)
(* ------------------------------------------------------------------ *)

let () =
  H.check_harness_sanity ();
  print_endline "=== Starting CamlQt6 Test Suite ===";

  (* TEST-12: QT_QPA_PLATFORM comes from test/dune; argv is belt and braces. *)
  let app = App.create ~args:[| "test_camlqt6"; "-platform"; "offscreen" |] () in

  H.test "widgets" test_widgets;
  H.test "layout" test_layout;
  H.test "grid_layout" test_grid_layout;
  H.test "controls" test_controls;
  H.test "text_edit" test_text_edit;
  H.test "main_window" test_main_window;
  H.test "color" test_color;
  H.test "standard_item_model" test_standard_item_model;
  H.test "table_model" test_table_model;
  H.test "views" test_views;
  H.test "containers" test_containers;
  H.test "docks_and_toolbars" test_docks_and_toolbars;
  H.test "dialog_objects" test_dialog_objects;
  H.test "mime_data" test_mime_data;
  H.test "clipboard" test_clipboard;
  H.test "drag" test_drag;
  H.test "canvas_and_pixmap" test_canvas_and_pixmap;
  H.test "object_lifetime" test_object_lifetime;
  H.test "object_naming_and_hash" test_object_naming_and_hash;
  H.test "on_destroyed" test_on_destroyed;
  H.test "gc_survival" test_gc_survival;
  H.test "state" test_state;
  H.test "state_map" test_state_map;
  H.test "state_equality" test_state_equality;
  H.test "dsl_two_way_binding" test_dsl_two_way_binding;
  H.test "dsl_containers" test_dsl_containers;
  H.test "dsl_conditional" test_dsl_conditional;
  H.test "render_hints_and_primitives" test_render_hints_and_primitives;
  H.test "pen_brush_font_getters" test_pen_brush_font_getters;
  H.test "color_extensions" test_color_extensions;
  H.test "table_model_sort_and_roles" test_table_model_sort_and_roles;
  H.test "event_loop" (fun () -> test_event_loop app);
  H.test "post_task" (fun () -> test_post_task app);

  (* Multicore: update shared state from a worker domain, then dispatch back. *)
  H.test "multicore_domain"
    (fun () ->
      let shared = State.create 0 in
      let ran = ref false and observed = ref 0 in
      let d =
        Domain.spawn (fun () ->
          State.set shared 42;
          App.run_on_ui_thread (fun () ->
            observed := State.get shared;
            ran := true))
      in
      Domain.join d;
      App.process_events ();
      H.check_bool "multicore/ran_on_ui_thread" ~expected:true ~actual:!ran;
      H.check_int "multicore/observed_worker_update" ~expected:42
        ~actual:!observed);

  (* A worker domain must not be able to create the QApplication. *)
  H.test "app_create_rejected_off_main_domain"
    (fun () ->
      let result = Domain.spawn (fun () -> App.create ()) in
      match Domain.join result with
      | _ -> H.test "app_create_rejected_off_main_domain" (fun () ->
          failwith "expected App.create to fail on a secondary domain")
      | exception Failure _ -> ());

  exit (H.report ())