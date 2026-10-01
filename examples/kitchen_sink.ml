open Camlqt6

let () =
  let app = App.create () in

  let main_win = MainWindow.create () in
  Widget.set_window_title main_win "CamlQt6 Kitchen Sink - Desktop Controls Showcase";
  Widget.resize main_win ~width:720 ~height:520;

  (* Status Bar *)
  let sb = MainWindow.status_bar main_win in
  StatusBar.show_message sb "Welcome to CamlQt6! Ready." ;

  (* Menu Bar *)
  let mb = MainWindow.menu_bar main_win in

  (* File Menu *)
  let file_menu = MenuBar.add_menu mb "&File" in
  let action_open = Menu.add_action_text file_menu "&Open File..." in
  Action.set_shortcut action_open "Ctrl+O";
  Action.on_triggered action_open (fun _ ->
    match FileDialog.get_open_file_name ~parent:main_win ~caption:"Open File" () with
    | Some path -> StatusBar.show_message sb (Printf.sprintf "Selected file: %s" path)
    | None -> StatusBar.show_message sb "File open cancelled."
  );

  Menu.add_separator file_menu;
  let action_exit = Menu.add_action_text file_menu "E&xit" in
  Action.set_shortcut action_exit "Ctrl+Q";
  Action.on_triggered action_exit (fun _ -> App.quit ());

  (* Help Menu *)
  let help_menu = MenuBar.add_menu mb "&Help" in
  let action_about = Menu.add_action_text help_menu "&About CamlQt6" in
  Action.on_triggered action_about (fun _ ->
    MessageBox.information
      ~parent:main_win
      ~title:"About CamlQt6"
      ~text:"CamlQt6: Pure, Type-Safe OCaml 5 bindings for Qt 6.\n\nRunning natively on WSL2 / Linux / Windows / macOS."
      ()
  );

  (* Central Widget *)
  let central = Widget.create () in
  let grid = Layout.Grid.create ~parent:central () in
  Layout.Grid.set_spacing grid 12;

  (* Left Column: Controls *)
  let left_box = Widget.create () in
  let left_layout = Layout.VBox.create ~parent:left_box () in

  let title_lbl = Label.create ~text:"Interactive Controls" () in
  Widget.set_style_sheet title_lbl "font-size: 14px; font-weight: bold; color: #2c3e50;";
  Layout.add_widget left_layout title_lbl;

  (* CheckBox & RadioButton *)
  let cb = CheckBox.create ~text:"Enable Live Sync" () in
  CheckBox.set_checked cb true;
  Layout.add_widget left_layout cb;

  let rb1 = RadioButton.create ~text:"Mode Alpha" () in
  let rb2 = RadioButton.create ~text:"Mode Beta" () in
  RadioButton.set_checked rb1 true;
  Layout.add_widget left_layout rb1;
  Layout.add_widget left_layout rb2;

  (* ComboBox *)
  let combo_lbl = Label.create ~text:"Select Theme / Accent:" () in
  Layout.add_widget left_layout combo_lbl;
  let combo = ComboBox.create () in
  ComboBox.add_items combo ["Emerald Green"; "Ocean Blue"; "Crimson Red"; "Midnight Dark"];
  Layout.add_widget left_layout combo;

  (* SpinBox + Slider + ProgressBar synchronized! *)
  let sync_lbl = Label.create ~text:"Synchronized Numeric Range:" () in
  Widget.set_style_sheet sync_lbl "font-weight: bold; margin-top: 10px;";
  Layout.add_widget left_layout sync_lbl;

  let spin = SpinBox.create () in
  SpinBox.set_range spin ~min:0 ~max:100;
  SpinBox.set_value spin 35;
  SpinBox.set_suffix spin "%";
  Layout.add_widget left_layout spin;

  let slider = Slider.create ~orientation:`Horizontal () in
  Slider.set_range slider ~min:0 ~max:100;
  Slider.set_value slider 35;
  Layout.add_widget left_layout slider;

  let progress = ProgressBar.create () in
  ProgressBar.set_range progress ~min:0 ~max:100;
  ProgressBar.set_value progress 35;
  Layout.add_widget left_layout progress;

  (* Connect Two-Way Sync *)
  let is_updating = ref false in
  Slider.on_value_changed slider (fun v ->
    if not !is_updating && CheckBox.is_checked cb then begin
      is_updating := true;
      SpinBox.set_value spin v;
      ProgressBar.set_value progress v;
      StatusBar.show_message sb (Printf.sprintf "Slider moved to %d%%" v);
      is_updating := false
    end
  );

  SpinBox.on_value_changed spin (fun v ->
    if not !is_updating && CheckBox.is_checked cb then begin
      is_updating := true;
      Slider.set_value slider v;
      ProgressBar.set_value progress v;
      StatusBar.show_message sb (Printf.sprintf "SpinBox set to %d%%" v);
      is_updating := false
    end
  );

  (* Dialog Button *)
  let dlg_btn = Button.create ~text:"Open Modal Dialog..." () in
  Widget.set_style_sheet dlg_btn "padding: 6px; background-color: #3498db; color: white; border-radius: 4px;";
  Layout.add_widget left_layout dlg_btn;

  Button.on_clicked dlg_btn (fun () ->
    let dlg = Dialog.create ~parent:main_win () in
    Widget.set_window_title dlg "Custom Modal Dialog";
    Widget.resize dlg ~width:280 ~height:140;
    let d_layout = Layout.VBox.create ~parent:dlg () in
    let d_lbl = Label.create ~text:"This is a modal dialog running inside CamlQt6!" () in
    Layout.add_widget d_layout d_lbl;
    let ok_btn = Button.create ~text:"Close Dialog" () in
    Button.on_clicked ok_btn (fun () -> Dialog.accept dlg);
    Layout.add_widget d_layout ok_btn;
    let ret = Dialog.exec dlg in
    StatusBar.show_message sb (Printf.sprintf "Dialog closed with code %d" ret)
  );

  Layout.add_stretch left_layout ();

  (* Right Column: TextEdit *)
  let right_box = Widget.create () in
  let right_layout = Layout.VBox.create ~parent:right_box () in

  let text_title = Label.create ~text:"Rich Text Editor & Output Log" () in
  Widget.set_style_sheet text_title "font-size: 14px; font-weight: bold; color: #2c3e50;";
  Layout.add_widget right_layout text_title;

  let text_edit = TextEdit.create () in
  TextEdit.set_plain_text text_edit
    "Welcome to the CamlQt6 showcase!\n\n\
     • Built using OCaml 5 with direct C++20 FFI\n\
     • Safe memory management via QPointer\n\
     • Re-entrant multicore domain lock safety\n\
     • Native performance with zero-cost OCaml FFI\n\n\
     Try moving the slider or selecting options on the left!";
  Layout.add_widget right_layout text_edit;

  ComboBox.on_current_text_changed combo (fun theme ->
    TextEdit.append text_edit (Printf.sprintf "\n[Theme changed to: %s]" theme);
    StatusBar.show_message sb (Printf.sprintf "Theme selected: %s" theme)
  );

  (* Place columns into main grid *)
  Layout.Grid.add_widget grid ~row:0 ~col:0 left_box;
  Layout.Grid.add_widget grid ~row:0 ~col:1 right_box;
  Layout.Grid.set_column_stretch grid ~col:0 ~stretch:1;
  Layout.Grid.set_column_stretch grid ~col:1 ~stretch:2;

  MainWindow.set_central_widget main_win central;

  Widget.show main_win;
  exit (App.exec app)
