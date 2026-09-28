open Oqt6

type tool = PenTool | RectTool | EllipseTool

type shape =
  | Freehand of (int * int) list * Gui.Color.t * int
  | Rect of int * int * int * int * Gui.Color.t * int
  | Ellipse of int * int * int * int * Gui.Color.t * int

let () =
  let app = App.create () in
  let win = MainWindow.create () in
  Widget.set_window_title win "OQt6 Interactive Drawing Canvas";
  Widget.resize win ~width:900 ~height:650;

  let central = Widget.create ~parent:win () in
  MainWindow.set_central_widget win central;

  let root_layout = Layout.VBox.create ~parent:central () in
  Widget.set_layout central root_layout;

  (* Controls toolbar / ribbon *)
  let controls = Widget.create ~parent:central () in
  let ctrl_layout = Layout.HBox.create ~parent:controls () in
  Widget.set_layout controls ctrl_layout;
  Layout.add_widget root_layout controls;

  let lbl_tool = Label.create ~text:"<b>Tool:</b>" ~parent:controls () in
  Layout.add_widget ctrl_layout lbl_tool;

  let combo_tool = ComboBox.create ~parent:controls () in
  ComboBox.add_items combo_tool ["Freehand Pen"; "Rectangle"; "Ellipse"];
  Layout.add_widget ctrl_layout combo_tool;

  let lbl_color = Label.create ~text:"<b>Color:</b>" ~parent:controls () in
  Layout.add_widget ctrl_layout lbl_color;

  let combo_color = ComboBox.create ~parent:controls () in
  ComboBox.add_items combo_color ["Black"; "Red"; "Blue"; "Green"; "Magenta"; "Dark Gray"];
  Layout.add_widget ctrl_layout combo_color;

  let lbl_size = Label.create ~text:"<b>Width:</b>" ~parent:controls () in
  Layout.add_widget ctrl_layout lbl_size;

  let spin_size = SpinBox.create ~parent:controls () in
  SpinBox.set_range spin_size ~min:1 ~max:30;
  SpinBox.set_value spin_size 3;
  Layout.add_widget ctrl_layout spin_size;

  let btn_clear = Button.create ~text:"Clear Canvas" ~parent:controls () in
  Layout.add_widget ctrl_layout btn_clear;

  Layout.add_stretch ctrl_layout ();

  let lbl_pos = Label.create ~text:"Cursor: (0, 0)" ~parent:controls () in
  Layout.add_widget ctrl_layout lbl_pos;

  (* Canvas *)
  let canvas = Canvas.create ~parent:central () in
  Canvas.set_mouse_tracking canvas true;
  Layout.add_widget root_layout ~stretch:1 canvas;

  (* Drawing state *)
  let current_tool = ref PenTool in
  let current_color = ref Color.black in
  let current_width = ref 3 in

  let shapes = ref [] in
  let is_drawing = ref false in
  let start_point = ref (0, 0) in
  let current_pos = ref (0, 0) in
  let current_pts = ref [] in

  let get_color_from_name = function
    | "Red" -> Color.red_color
    | "Blue" -> Color.blue_color
    | "Green" -> Color.green_color
    | "Magenta" -> Color.magenta
    | "Dark Gray" -> Color.dark_gray
    | _ -> Color.black
  in

  ComboBox.on_current_text_changed combo_tool (fun txt ->
    current_tool := match txt with
      | "Rectangle" -> RectTool
      | "Ellipse" -> EllipseTool
      | _ -> PenTool
  );

  ComboBox.on_current_text_changed combo_color (fun txt ->
    current_color := get_color_from_name txt
  );

  SpinBox.on_value_changed spin_size (fun v ->
    current_width := v
  );

  Button.on_clicked btn_clear (fun () ->
    shapes := [];
    current_pts := [];
    is_drawing := false;
    Canvas.update canvas
  );

  (* Canvas Events *)
  Canvas.on_mouse_press canvas (fun ev ->
    if ev.button = `Left_button then begin
      is_drawing := true;
      start_point := (ev.x, ev.y);
      current_pos := (ev.x, ev.y);
      if !current_tool = PenTool then
        current_pts := [(ev.x, ev.y)];
      Canvas.update canvas
    end
  );

  Canvas.on_mouse_move canvas (fun ev ->
    current_pos := (ev.x, ev.y);
    Label.set_text lbl_pos (Printf.sprintf "Cursor: (%d, %d)" ev.x ev.y);
    if !is_drawing then begin
      if !current_tool = PenTool then
        current_pts := (ev.x, ev.y) :: !current_pts;
      Canvas.update canvas
    end
  );

  Canvas.on_mouse_release canvas (fun ev ->
    if !is_drawing && ev.button = `Left_button then begin
      is_drawing := false;
      let (sx, sy) = !start_point in
      let ex, ey = ev.x, ev.y in
      let x = min sx ex in
      let y = min sy ey in
      let w = abs (ex - sx) in
      let h = abs (ey - sy) in
      (match !current_tool with
       | PenTool ->
           shapes := Freehand (List.rev !current_pts, !current_color, !current_width) :: !shapes;
           current_pts := []
       | RectTool ->
           if w > 0 && h > 0 then
             shapes := Rect (x, y, w, h, !current_color, !current_width) :: !shapes
       | EllipseTool ->
           if w > 0 && h > 0 then
             shapes := Ellipse (x, y, w, h, !current_color, !current_width) :: !shapes);
      Canvas.update canvas
    end
  );

  Canvas.on_key_press canvas (fun ev ->
    if ev.text = "c" || ev.text = "C" then begin
      shapes := [];
      current_pts := [];
      Canvas.update canvas
    end
  );

  Canvas.on_paint canvas (fun p ->
    let w = Widget.width canvas in
    let h = Widget.height canvas in
    (* Draw clean white background *)
    Painter.fill_rect p ~x:0 ~y:0 ~width:w ~height:h Color.white;

    (* Draw subtle grid pattern *)
    let grid_pen = Pen.create ~color:(Color.rgb 242 242 242 ()) ~width:1 () in
    Painter.set_pen p grid_pen;
    let step = 30 in
    let rec draw_v x =
      if x < w then (Painter.draw_line p ~x1:x ~y1:0 ~x2:x ~y2:h; draw_v (x + step))
    in
    let rec draw_h y =
      if y < h then (Painter.draw_line p ~x1:0 ~y1:y ~x2:w ~y2:y; draw_h (y + step))
    in
    draw_v step;
    draw_h step;

    (* Draw watermark header *)
    let font = Font.create ~family:"sans-serif" ~point_size:10 ~bold:true () in
    Painter.set_font p font;
    let text_pen = Pen.create ~color:(Color.rgb 180 180 180 ()) () in
    Painter.set_pen p text_pen;
    Painter.draw_text p ~x:15 ~y:25 "OQt6 Vector Canvas - Paint freely or draw geometric shapes";

    (* Draw completed shapes *)
    List.iter (function
      | Freehand (pts, col, width) ->
          let pen = Pen.create ~color:col ~width () in
          Painter.set_pen p pen;
          let rec draw_segments = function
            | (x1, y1) :: ((x2, y2) :: _ as rest) ->
                Painter.draw_line p ~x1 ~y1 ~x2 ~y2;
                draw_segments rest
            | _ -> ()
          in
          draw_segments pts
      | Rect (x, y, rw, rh, col, width) ->
          let pen = Pen.create ~color:col ~width () in
          Painter.set_pen p pen;
          Painter.set_brush p (Brush.create ~style:`No_brush ());
          Painter.draw_rect p ~x ~y ~width:rw ~height:rh
      | Ellipse (x, y, ew, eh, col, width) ->
          let pen = Pen.create ~color:col ~width () in
          Painter.set_pen p pen;
          Painter.set_brush p (Brush.create ~style:`No_brush ());
          Painter.draw_ellipse p ~x ~y ~width:ew ~height:eh
    ) (List.rev !shapes);

    (* Draw active shape in progress *)
    if !is_drawing then begin
      match !current_tool with
      | PenTool ->
          let pen = Pen.create ~color:!current_color ~width:!current_width () in
          Painter.set_pen p pen;
          let rec draw_segments = function
            | (x1, y1) :: ((x2, y2) :: _ as rest) ->
                Painter.draw_line p ~x1 ~y1 ~x2 ~y2;
                draw_segments rest
            | _ -> ()
          in
          draw_segments (List.rev !current_pts)
      | RectTool ->
          let (sx, sy) = !start_point in
          let (cx, cy) = !current_pos in
          let x = min sx cx in
          let y = min sy cy in
          let rw = abs (cx - sx) in
          let rh = abs (cy - sy) in
          let pen = Pen.create ~color:!current_color ~width:!current_width ~style:`Dash_line () in
          Painter.set_pen p pen;
          Painter.set_brush p (Brush.create ~style:`No_brush ());
          Painter.draw_rect p ~x ~y ~width:rw ~height:rh
      | EllipseTool ->
          let (sx, sy) = !start_point in
          let (cx, cy) = !current_pos in
          let x = min sx cx in
          let y = min sy cy in
          let ew = abs (cx - sx) in
          let eh = abs (cy - sy) in
          let pen = Pen.create ~color:!current_color ~width:!current_width ~style:`Dash_line () in
          Painter.set_pen p pen;
          Painter.set_brush p (Brush.create ~style:`No_brush ());
          Painter.draw_ellipse p ~x ~y ~width:ew ~height:eh
    end;

    (* Draw canvas border *)
    let border_pen = Pen.create ~color:(Color.rgb 190 190 190 ()) ~width:1 () in
    Painter.set_pen p border_pen;
    Painter.set_brush p (Brush.create ~style:`No_brush ());
    Painter.draw_rect p ~x:0 ~y:0 ~width:(w - 1) ~height:(h - 1)
  );

  let status_bar = MainWindow.status_bar win in
  StatusBar.show_message status_bar "Ready. Click and drag to draw. Press 'C' to clear canvas.";

  Widget.show win;
  exit (App.exec app)
