(** CamlQt6 Phase 4 Demo: Developer Workbench
    Showcases QTabWidget, QSplitter, QScrollArea, QGroupBox, QToolBar,
    QDockWidget, QPixmap, QIcon, QCursor, and standard Qt Dialogs. *)

open Camlqt6

let create_colored_icon r g b =
  let pm = Pixmap.create ~width:24 ~height:24 in
  Pixmap.fill pm (Color.rgb r g b ());
  Icon.from_pixmap pm

let () =
  let app = App.create () in
  let main_win = MainWindow.create () in
  Widget.set_window_title main_win "CamlQt6 Developer Workbench";
  Widget.resize main_win ~width:1050 ~height:700;

  (* Set App / Window Icon *)
  let app_icon = create_colored_icon 41 128 185 in
  MainWindow.set_window_icon main_win app_icon;

  let status_bar = MainWindow.status_bar main_win in
  StatusBar.show_message status_bar "Ready";

  (* --- Toolbar --- *)
  let toolbar = MainWindow.add_tool_bar_title main_win "Main Toolbar" in
  let icon_blue = create_colored_icon 52 152 219 in
  let icon_green = create_colored_icon 46 204 113 in
  let icon_orange = create_colored_icon 230 126 34 in

  let act_new = Action.create ~text:"&New" () in
  Action.set_icon act_new icon_blue;
  Action.set_shortcut act_new "Ctrl+N";
  ToolBar.add_action toolbar act_new;

  let act_build = Action.create ~text:"&Build" () in
  Action.set_icon act_build icon_green;
  Action.set_shortcut act_build "Ctrl+B";
  ToolBar.add_action toolbar act_build;

  ToolBar.add_separator toolbar;

  let act_settings = Action.create ~text:"&Settings" () in
  Action.set_icon act_settings icon_orange;
  ToolBar.add_action toolbar act_settings;

  (* --- Left Dock Widget: Project Explorer --- *)
  let dock = DockWidget.create ~title:"Project Explorer" ~parent:main_win () in
  let tree = TreeView.create ~parent:dock () in
  let proj_model = StandardItemModel.create ~rows:0 ~cols:1 () in
  StandardItemModel.set_horizontal_header_labels proj_model ["Workspace"];
  StandardItemModel.append_row proj_model ["src/"];
  StandardItemModel.append_row proj_model ["  core.ml"];
  StandardItemModel.append_row proj_model ["  gui.ml"];
  StandardItemModel.append_row proj_model ["  widgets.ml"];
  StandardItemModel.append_row proj_model ["  CamlQt6.ml"];
  StandardItemModel.append_row proj_model ["test/"];
  StandardItemModel.append_row proj_model ["  test_CamlQt6.ml"];
  StandardItemModel.append_row proj_model ["examples/"];
  StandardItemModel.append_row proj_model ["  workbench_demo.ml"];
  StandardItemModel.append_row proj_model ["dune-project"];
  TreeView.set_model tree proj_model;
  TreeView.set_alternating_row_colors tree true;
  DockWidget.set_widget dock tree;
  MainWindow.add_dock_widget main_win `Left_dock dock;

  (* --- Central Splitter (Editor on top/left, Console/Tools on bottom/right) --- *)
  let main_splitter = Splitter.create ~orientation:`Vertical ~parent:main_win () in
  let h_splitter = Splitter.create ~orientation:`Horizontal ~parent:main_splitter () in

  (* Top-Left: TabWidget for Documents *)
  let editor_tabs = TabWidget.create ~parent:h_splitter () in
  TabWidget.set_tabs_closable editor_tabs true;
  TabWidget.set_movable editor_tabs true;

  (* Tab 1: Code Editor *)
  let code_edit = TextEdit.create ~parent:editor_tabs () in
  Widget.set_style_sheet code_edit "font-family: monospace; font-size: 11pt;";
  TextEdit.set_plain_text code_edit
    ("(* Welcome to CamlQt6 Developer Workbench *)\n" ^
     "open Camlqt6\n\n" ^
     "let build_project () =\n" ^
     "  print_endline \"Building with Dune...\";\n" ^
     "  Timer.single_shot 500 (fun () ->\n" ^
     "    print_endline \"Build completed with 0 errors!\")\n");
  let _ = TabWidget.add_tab editor_tabs ~label:"main.ml" code_edit in
  TabWidget.set_tab_icon editor_tabs 0 icon_blue;

  (* Tab 2: Canvas Preview *)
  let canvas = Canvas.create ~parent:editor_tabs () in
  Canvas.set_mouse_tracking canvas true;
  let canvas_brush_color = ref (Color.rgb 41 128 185 ()) in
  let canvas_draw_pos = ref (150, 150) in
  Canvas.on_paint canvas (fun painter ->
    Painter.set_pen painter (Pen.create ~color:(Color.rgb 50 50 50 ()) ~width:2 ());
    Painter.set_brush painter (Brush.create ~color:!canvas_brush_color ());
    let (cx, cy) = !canvas_draw_pos in
    Painter.draw_rounded_rect painter ~x:(cx - 60) ~y:(cy - 60) ~width:120 ~height:120 ~x_radius:15.0 ~y_radius:15.0;
    Painter.set_font painter (Font.create ~family:"Sans" ~point_size:12 ~bold:true ());
    Painter.draw_text painter ~x:(cx - 45) ~y:(cy + 5) "CamlQt6 Canvas";

    (* Draw test pixmap stamps in corners *)
    let stamp = Pixmap.create ~width:20 ~height:20 in
    Pixmap.fill stamp (Color.rgb 231 76 60 ());
    Painter.draw_pixmap painter ~x:20 ~y:20 stamp;
    Painter.draw_pixmap painter ~x:260 ~y:20 stamp
  );
  Canvas.on_mouse_move canvas (fun ev ->
    canvas_draw_pos := (ev.x, ev.y);
    Canvas.update canvas
  );
  let _ = TabWidget.add_tab editor_tabs ~label:"Canvas Preview" canvas in
  TabWidget.set_tab_icon editor_tabs 1 icon_green;

  (* Top-Right: Inspector Panel inside a ScrollArea with GroupBoxes *)
  let inspector_scroll = ScrollArea.create ~parent:h_splitter () in
  ScrollArea.set_widget_resizable inspector_scroll true;
  let inspector_container = Widget.create () in
  let insp_layout = Layout.VBox.create ~parent:inspector_container () in

  (* GroupBox: Canvas Style *)
  let gb_style = GroupBox.create ~title:"Canvas Settings" ~parent:inspector_container () in
  let gb_style_layout = Layout.VBox.create ~parent:gb_style () in
  let lbl_color = Label.create ~text:"Shape Color: #2980b9" ~parent:gb_style () in
  let btn_pick_color = Button.create ~text:"Pick Color (QColorDialog)..." ~parent:gb_style () in
  let btn_pick_font = Button.create ~text:"Pick Font (QFontDialog)..." ~parent:gb_style () in
  Layout.add_widget gb_style_layout lbl_color;
  Layout.add_widget gb_style_layout btn_pick_color;
  Layout.add_widget gb_style_layout btn_pick_font;
  Widget.set_layout gb_style gb_style_layout;
  Layout.add_widget insp_layout gb_style;

  (* GroupBox: Dialog Helpers *)
  let gb_dialogs = GroupBox.create ~title:"Interactive Dialogs" ~parent:inspector_container () in
  let gb_dialogs_layout = Layout.VBox.create ~parent:gb_dialogs () in
  let btn_ask_name = Button.create ~text:"Ask Text (QInputDialog)..." ~parent:gb_dialogs () in
  let btn_ask_num = Button.create ~text:"Ask Integer (QInputDialog)..." ~parent:gb_dialogs () in
  let btn_ask_item = Button.create ~text:"Ask Choice (QInputDialog)..." ~parent:gb_dialogs () in
  let btn_progress = Button.create ~text:"Simulate Task (QProgressDialog)..." ~parent:gb_dialogs () in
  Layout.add_widget gb_dialogs_layout btn_ask_name;
  Layout.add_widget gb_dialogs_layout btn_ask_num;
  Layout.add_widget gb_dialogs_layout btn_ask_item;
  Layout.add_widget gb_dialogs_layout btn_progress;
  Widget.set_layout gb_dialogs gb_dialogs_layout;
  Layout.add_widget insp_layout gb_dialogs;

  Widget.set_layout inspector_container insp_layout;
  ScrollArea.set_widget inspector_scroll inspector_container;

  Splitter.add_widget h_splitter editor_tabs;
  Splitter.add_widget h_splitter inspector_scroll;
  Splitter.set_stretch_factor h_splitter ~index:0 ~stretch:3;
  Splitter.set_stretch_factor h_splitter ~index:1 ~stretch:1;

  (* Bottom Pane: Output Console *)
  let console_box = GroupBox.create ~title:"Build & Event Log" ~parent:main_splitter () in
  let console_layout = Layout.VBox.create ~parent:console_box () in
  let console_edit = TextEdit.create ~parent:console_box () in
  Widget.set_style_sheet console_edit "font-family: monospace; font-size: 10pt; background: #1e1e1e; color: #d4d4d4;";
  TextEdit.set_read_only console_edit true;
  TextEdit.set_plain_text console_edit "[Workbench] Initialized successfully.\n";
  Layout.add_widget console_layout console_edit;
  Widget.set_layout console_box console_layout;

  let log msg =
    TextEdit.append console_edit msg;
    StatusBar.show_message status_bar msg
  in

  Splitter.add_widget main_splitter h_splitter;
  Splitter.add_widget main_splitter console_box;
  Splitter.set_stretch_factor main_splitter ~index:0 ~stretch:4;
  Splitter.set_stretch_factor main_splitter ~index:1 ~stretch:1;

  MainWindow.set_central_widget main_win main_splitter;

  (* --- Connections --- *)
  Action.on_triggered act_new (fun _ ->
    let tab_count = TabWidget.count editor_tabs in
    let new_te = TextEdit.create ~parent:editor_tabs () in
    let name = Printf.sprintf "untitled_%d.ml" tab_count in
    let idx = TabWidget.add_tab editor_tabs ~label:name new_te in
    TabWidget.set_current_index editor_tabs idx;
    log (Printf.sprintf "Created %s" name)
  );

  Action.on_triggered act_build (fun _ ->
    log "[Build] Compiling workspace with dune...";
    Timer.single_shot 600 (fun () ->
      log "[Build] Finished: 0 errors, 0 warnings (exit code: 0)."
    )
  );

  TabWidget.on_current_changed editor_tabs (fun idx ->
    let txt = TabWidget.tab_text editor_tabs idx in
    StatusBar.show_message status_bar (Printf.sprintf "Switched to tab: %s" txt)
  );

  TabWidget.on_tab_close_requested editor_tabs (fun idx ->
    let txt = TabWidget.tab_text editor_tabs idx in
    TabWidget.remove_tab editor_tabs idx;
    log (Printf.sprintf "Closed tab: %s" txt)
  );

  Button.on_clicked btn_pick_color (fun () ->
    match ColorDialog.get_color ~parent:main_win ~initial:!canvas_brush_color ~title:"Choose Canvas Color" () with
    | None -> log "[ColorDialog] Cancelled"
    | Some c ->
      canvas_brush_color := c;
      let hex = Printf.sprintf "#%02x%02x%02x" (Color.red c) (Color.green c) (Color.blue c) in
      Label.set_text lbl_color (Printf.sprintf "Shape Color: %s" hex);
      Canvas.update canvas;
      log (Printf.sprintf "[ColorDialog] Selected color: %s" hex)
  );

  Button.on_clicked btn_pick_font (fun () ->
    match FontDialog.get_font ~parent:main_win ~title:"Choose Editor Font" () with
    | None -> log "[FontDialog] Cancelled"
    | Some f ->
      let fam = Font.family f in
      let sz = Font.point_size f in
      let sz = if sz > 0 then sz else 11 in
      Widget.set_style_sheet code_edit (Printf.sprintf "font-family: '%s'; font-size: %dpt;" fam sz);
      log (Printf.sprintf "[FontDialog] Selected font: %s %dpt" fam sz)
  );

  Button.on_clicked btn_ask_name (fun () ->
    match InputDialog.get_text ~parent:main_win ~title:"User Input" ~label:"Enter your project name:" ~initial:"my_qt_app" () with
    | None -> log "[InputDialog] Name entry cancelled"
    | Some name -> log (Printf.sprintf "[InputDialog] Project name entered: %s" name)
  );

  Button.on_clicked btn_ask_num (fun () ->
    match InputDialog.get_int ~parent:main_win ~title:"Port Configuration" ~label:"Enter server port:" ~value:8080 ~min:1024 ~max:65535 () with
    | None -> log "[InputDialog] Port entry cancelled"
    | Some port -> log (Printf.sprintf "[InputDialog] Selected port: %d" port)
  );

  Button.on_clicked btn_ask_item (fun () ->
    let options = ["Debug"; "Release"; "RelWithDebInfo"; "MinSizeRel"] in
    match InputDialog.get_item ~parent:main_win ~title:"Build Target" ~label:"Select build profile:" ~items:options () with
    | None -> log "[InputDialog] Profile selection cancelled"
    | Some profile -> log (Printf.sprintf "[InputDialog] Build profile selected: %s" profile)
  );

  Button.on_clicked btn_progress (fun () ->
    let pd = ProgressDialog.create ~label_text:"Compiling native packages..." ~cancel_button_text:"Abort" ~min:0 ~max:100 ~parent:main_win () in
    ProgressDialog.set_value pd 0;
    let step = ref 0 in
    let rec advance () =
      if !step <= 100 && not (ProgressDialog.was_canceled pd) then begin
        ProgressDialog.set_value pd !step;
        step := !step + 10;
        Timer.single_shot 80 advance
      end else if ProgressDialog.was_canceled pd then begin
        log "[ProgressDialog] Compilation aborted by user."
      end else begin
        log "[ProgressDialog] Compilation completed successfully (100%)."
      end
    in
    advance ()
  );

  Widget.show main_win;
  exit (App.exec app)
