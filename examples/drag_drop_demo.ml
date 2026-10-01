open Camlqt6

let () =
  let app = App.create () in
  let win = MainWindow.create () in
  Widget.set_window_title win "CamlQt6 Drag, Drop & Clipboard Studio";
  Widget.resize win ~width:750 ~height:480;

  let central = Widget.create ~parent:win () in
  MainWindow.set_central_widget win central;
  let root_layout = Layout.HBox.create ~parent:central () in
  Layout.set_spacing root_layout 16;
  Layout.set_contents_margins root_layout ~left:16 ~top:16 ~right:16 ~bottom:16;

  let status_bar = MainWindow.status_bar win in
  StatusBar.show_message status_bar "Ready. Drag items or use clipboard actions.";

  (* === LEFT PANEL: Clipboard Controls & Drag Source === *)
  let left_group = GroupBox.create ~title:"Clipboard & Drag Sources" ~parent:central () in
  let left_layout = Layout.VBox.create ~parent:left_group () in
  Layout.set_spacing left_layout 10;
  Layout.add_widget root_layout left_group;

  let clip_label = Label.create ~text:"Clipboard Text Editor:" ~parent:left_group () in
  Layout.add_widget left_layout clip_label;

  let clip_edit = LineEdit.create ~text:"Drag or Copy this text!" ~parent:left_group () in
  Layout.add_widget left_layout clip_edit;

  let btn_row = Widget.create ~parent:left_group () in
  let btn_layout = Layout.HBox.create ~parent:btn_row () in
  Layout.set_spacing btn_layout 8;
  Layout.add_widget left_layout btn_row;

  let copy_btn = Button.create ~text:"Copy Text" ~parent:btn_row () in
  let paste_btn = Button.create ~text:"Paste Text" ~parent:btn_row () in
  let clear_btn = Button.create ~text:"Clear Clipboard" ~parent:btn_row () in
  Layout.add_widget btn_layout copy_btn;
  Layout.add_widget btn_layout paste_btn;
  Layout.add_widget btn_layout clear_btn;

  Button.on_clicked copy_btn (fun () ->
    let txt = LineEdit.text clip_edit in
    Clipboard.set_text txt;
    StatusBar.show_message status_bar (Printf.sprintf "Copied to clipboard: '%s'" txt)
  );

  Button.on_clicked paste_btn (fun () ->
    match Clipboard.text () with
    | Some txt ->
      LineEdit.set_text clip_edit txt;
      StatusBar.show_message status_bar (Printf.sprintf "Pasted from clipboard: '%s'" txt)
    | None ->
      StatusBar.show_message status_bar "Clipboard does not contain text!"
  );

  Button.on_clicked clear_btn (fun () ->
    Clipboard.clear ();
    StatusBar.show_message status_bar "Clipboard cleared."
  );

  (* Clipboard live change listener *)
  Clipboard.on_changed (fun () ->
    match Clipboard.text () with
    | Some s -> StatusBar.show_message status_bar (Printf.sprintf "[Signal] Clipboard updated: '%s'" s)
    | None -> StatusBar.show_message status_bar "[Signal] Clipboard cleared or non-text content set."
  );

  let drag_hint = Label.create ~text:"Drag Source (Click and drag box below):" ~parent:left_group () in
  Layout.add_widget left_layout drag_hint;

  (* Draggable Canvas source *)
  let drag_source = Canvas.create ~parent:left_group () in
  Widget.set_fixed_size drag_source ~width:320 ~height:180;
  Layout.add_widget left_layout drag_source;

  Canvas.on_paint drag_source (fun p ->
    Painter.set_pen p (Pen.create ~color:(Color.rgb 80 80 180 ()) ~width:2 ());
    Painter.set_brush p (Brush.create ~color:(Color.rgb 230 240 255 ()) ());
    Painter.draw_rounded_rect p ~x:10 ~y:10 ~width:300 ~height:160 ~x_radius:8.0 ~y_radius:8.0;
    Painter.set_pen p (Pen.create ~color:(Color.rgb 40 40 100 ()) ());
    Painter.set_font p (Font.create ~bold:true ~point_size:11 ());
    Painter.draw_text p ~x:25 ~y:50 "Press & Drag from here!";
    Painter.set_font p (Font.create ~point_size:9 ~italic:true ());
    Painter.draw_text p ~x:25 ~y:85 "Drags text to drop target on the right";
    Painter.draw_text p ~x:25 ~y:115 "or to external desktop applications"
  );

  Canvas.on_mouse_press drag_source (fun ev ->
    if ev.button = `Left_button then begin
      let drag = Drag.create drag_source in
      let mime = MimeData.create () in
      let payload = LineEdit.text clip_edit in
      MimeData.set_text mime payload;
      Drag.set_mime_data drag mime;

      (* Create custom drag preview pixmap *)
      let pm = Pixmap.create ~width:120 ~height:32 in
      Pixmap.fill pm (Color.rgb 70 130 180 ());
      Drag.set_pixmap drag pm;
      Drag.set_hot_spot drag ~x:10 ~y:10;

      StatusBar.show_message status_bar "Dragging initiated...";
      let action = Drag.exec drag in
      let action_str = match action with
        | `Copy -> "Copied"
        | `Move -> "Moved"
        | `Link -> "Linked"
        | `Ignore -> "Cancelled"
      in
      StatusBar.show_message status_bar (Printf.sprintf "Drag completed: %s" action_str)
    end
  );

  (* === RIGHT PANEL: Drop Target Canvas === *)
  let right_group = GroupBox.create ~title:"Drop Target Canvas" ~parent:central () in
  let right_layout = Layout.VBox.create ~parent:right_group () in
  Layout.set_spacing right_layout 10;
  Layout.add_widget root_layout right_group;

  let target_hint = Label.create ~text:"Accepts text & file drops from inside or outside CamlQt6:" ~parent:right_group () in
  Layout.add_widget right_layout target_hint;

  let drop_target = Canvas.create ~parent:right_group () in
  Widget.set_fixed_size drop_target ~width:350 ~height:320;
  Layout.add_widget right_layout drop_target;

  let is_hovering = ref false in
  let dropped_items = ref ["<Drop something here>"] in

  Canvas.on_paint drop_target (fun p ->
    let bg_color =
      if !is_hovering then Color.rgb 220 255 220 ()
      else Color.rgb 250 250 250 ()
    in
    let border_color =
      if !is_hovering then Color.rgb 50 180 50 ()
      else Color.rgb 180 180 180 ()
    in
    Painter.set_pen p (Pen.create ~color:border_color ~width:2 ~style:(if !is_hovering then `Solid_line else `Dash_line) ());
    Painter.set_brush p (Brush.create ~color:bg_color ());
    Painter.draw_rounded_rect p ~x:10 ~y:10 ~width:330 ~height:300 ~x_radius:8.0 ~y_radius:8.0;

    Painter.set_pen p (Pen.create ~color:(Color.rgb 30 30 30 ()) ());
    Painter.set_font p (Font.create ~bold:true ~point_size:10 ());
    Painter.draw_text p ~x:25 ~y:40 "Dropped Items History:";

    Painter.set_font p (Font.create ~point_size:9 ());
    List.iteri (fun i item ->
      let y = 70 + (i * 24) in
      if y < 290 then
        Painter.draw_text p ~x:30 ~y (Printf.sprintf "%d. %s" (i + 1) item)
    ) (List.rev !dropped_items)
  );

  Canvas.on_drag_enter drop_target (fun ~x:_ ~y:_ mime ->
    if MimeData.has_text mime || MimeData.has_urls mime then begin
      is_hovering := true;
      Canvas.update drop_target;
      StatusBar.show_message status_bar "Drag entered drop target (accepted)";
      true
    end else false
  );

  Canvas.on_drag_leave drop_target (fun () ->
    is_hovering := false;
    Canvas.update drop_target;
    StatusBar.show_message status_bar "Drag left drop target"
  );

  Canvas.on_drop drop_target (fun ~x:_ ~y:_ mime ->
    is_hovering := false;
    let text_content =
      if MimeData.has_urls mime then
        "URLs: " ^ String.concat ", " (MimeData.urls mime)
      else match MimeData.text mime with
        | Some t -> t
        | None -> "<unknown>"
    in
    dropped_items := text_content :: !dropped_items;
    Canvas.update drop_target;
    StatusBar.show_message status_bar (Printf.sprintf "Received Drop: '%s'" text_content)
  );

  Widget.show win;
  exit (App.exec app)
