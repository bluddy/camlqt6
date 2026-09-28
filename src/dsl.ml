(** OQt6 DSL: Declarative and Reactive UI Framework for Qt 6 *)

module State = struct
  type 'a t = {
    mutable value : 'a;
    mutable listeners : ('a -> unit) list;
  }

  let create initial = {
    value = initial;
    listeners = [];
  }

  let get s = s.value

  let set s new_val =
    if s.value <> new_val then begin
      s.value <- new_val;
      List.iter (fun f -> f new_val) s.listeners
    end

  let update s f = set s (f s.value)

  let subscribe s f =
    s.listeners <- f :: s.listeners;
    f s.value

  let map f src =
    let derived = create (f src.value) in
    subscribe src (fun v -> set derived (f v));
    derived

  let map2 f s1 s2 =
    let derived = create (f s1.value s2.value) in
    let update () = set derived (f s1.value s2.value) in
    subscribe s1 (fun _ -> update ());
    subscribe s2 (fun _ -> update ());
    derived
end

type node =
  | Widget of (parent:Widgets.qwidget Core.t option -> Widgets.qwidget Core.t)
  | Spacing of int
  | Stretch of int option

(** {1 Layouts & Containers} *)

let vbox ?spacing ?margin ?style children =
  Widget (fun ~parent ->
    let w = Widgets.Widget.create ?parent () in
    let l = Widgets.Layout.VBox.create ~parent:w () in
    Option.iter (Widgets.Layout.set_spacing l) spacing;
    Option.iter (Widgets.Layout.set_margin l) margin;
    Option.iter (Widgets.Widget.set_style_sheet w) style;
    List.iter (function
      | Widget f ->
        let child = f ~parent:(Some w) in
        Widgets.Layout.add_widget l child
      | Spacing n -> Widgets.Layout.add_spacing l n
      | Stretch s -> Widgets.Layout.add_stretch l ?stretch:s ()
    ) children;
    Widgets.Widget.set_layout w l;
    w
  )

let hbox ?spacing ?margin ?style children =
  Widget (fun ~parent ->
    let w = Widgets.Widget.create ?parent () in
    let l = Widgets.Layout.HBox.create ~parent:w () in
    Option.iter (Widgets.Layout.set_spacing l) spacing;
    Option.iter (Widgets.Layout.set_margin l) margin;
    Option.iter (Widgets.Widget.set_style_sheet w) style;
    List.iter (function
      | Widget f ->
        let child = f ~parent:(Some w) in
        Widgets.Layout.add_widget l child
      | Spacing n -> Widgets.Layout.add_spacing l n
      | Stretch s -> Widgets.Layout.add_stretch l ?stretch:s ()
    ) children;
    Widgets.Widget.set_layout w l;
    w
  )

let grid ?spacing ?margin items =
  Widget (fun ~parent ->
    let w = Widgets.Widget.create ?parent () in
    let gl = Widgets.Layout.Grid.create ~parent:w () in
    Option.iter (Widgets.Layout.set_spacing gl) spacing;
    Option.iter (Widgets.Layout.set_margin gl) margin;
    List.iter (fun (row, col, child_node) ->
      match child_node with
      | Widget f ->
        let child = f ~parent:(Some w) in
        Widgets.Layout.Grid.add_widget gl ~row ~col child
      | _ -> ()
    ) items;
    Widgets.Widget.set_layout w gl;
    w
  )

let split ?orientation ?sizes children =
  Widget (fun ~parent ->
    let sp = Widgets.Splitter.create ?orientation ?parent () in
    let sp_w = Widgets.Widget.as_widget sp in
    List.iter (function
      | Widget f ->
        let child = f ~parent:(Some sp_w) in
        Widgets.Splitter.add_widget sp child
      | _ -> ()
    ) children;
    Option.iter (Widgets.Splitter.set_sizes sp) sizes;
    sp_w
  )

let tabs pages =
  Widget (fun ~parent ->
    let tw = Widgets.TabWidget.create ?parent () in
    let tw_w = Widgets.Widget.as_widget tw in
    List.iter (fun (title, child_node) ->
      match child_node with
      | Widget f ->
        let child = f ~parent:(Some tw_w) in
        let _ = Widgets.TabWidget.add_tab tw ~label:title child in ()
      | _ -> ()
    ) pages;
    tw_w
  )

let scroll ?(resizable = true) child_node =
  Widget (fun ~parent ->
    let sa = Widgets.ScrollArea.create ?parent () in
    let sa_w = Widgets.Widget.as_widget sa in
    Widgets.ScrollArea.set_widget_resizable sa resizable;
    (match child_node with
     | Widget f ->
       let child = f ~parent:(Some sa_w) in
       Widgets.ScrollArea.set_widget sa child
     | _ -> ());
    sa_w
  )

let group ?title ?(checkable = false) ?checked child_node =
  Widget (fun ~parent ->
    let gb = Widgets.GroupBox.create ?title ?parent () in
    let gb_w = Widgets.Widget.as_widget gb in
    let is_chk = checkable || Option.is_some checked in
    if is_chk then Widgets.GroupBox.set_checkable gb true;
    Option.iter (fun s ->
      Widgets.GroupBox.set_checked gb (State.get s);
      State.subscribe s (fun b ->
        if Widgets.GroupBox.is_checked gb <> b then Widgets.GroupBox.set_checked gb b);
      Widgets.GroupBox.on_toggled gb (fun b ->
        if State.get s <> b then State.set s b)
    ) checked;
    let l = Widgets.Layout.VBox.create ~parent:gb () in
    (match child_node with
     | Widget f ->
       let child = f ~parent:(Some gb_w) in
       Widgets.Layout.add_widget l child
     | _ -> ());
    Widgets.Widget.set_layout gb l;
    gb_w
  )

let spacing n = Spacing n
let stretch ?factor () = Stretch factor

(** {1 Reactive Control Flow} *)

let match_s state pages =
  Widget (fun ~parent ->
    let sw = Widgets.StackedWidget.create ?parent () in
    let sw_w = Widgets.Widget.as_widget sw in
    List.iter (function
      | Widget f ->
        let child = f ~parent:(Some sw_w) in
        let _ = Widgets.StackedWidget.add_widget sw child in ()
      | _ -> ()
    ) pages;
    let count = Widgets.StackedWidget.count sw in
    State.subscribe state (fun idx ->
      if idx >= 0 && idx < count then
        Widgets.StackedWidget.set_current_index sw idx
    );
    sw_w
  )

let cond state ~true_node ~false_node =
  let idx_state = State.map (fun b -> if b then 0 else 1) state in
  match_s idx_state [true_node; false_node]

(** {1 Widgets} *)

let label ?style text =
  Widget (fun ~parent ->
    let lbl = Widgets.Label.create ~text ?parent () in
    Option.iter (Widgets.Widget.set_style_sheet lbl) style;
    Widgets.Widget.as_widget lbl
  )

let label_s ?style s =
  Widget (fun ~parent ->
    let lbl = Widgets.Label.create ~text:(State.get s) ?parent () in
    Option.iter (Widgets.Widget.set_style_sheet lbl) style;
    State.subscribe s (Widgets.Label.set_text lbl);
    Widgets.Widget.as_widget lbl
  )

let button ?icon ?style ?enabled_s ?on_click text =
  Widget (fun ~parent ->
    let btn = Widgets.Button.create ~text ?parent () in
    Option.iter (Widgets.Button.set_icon btn) icon;
    Option.iter (Widgets.Widget.set_style_sheet btn) style;
    Option.iter (fun s -> State.subscribe s (Widgets.Widget.set_enabled btn)) enabled_s;
    Option.iter (Widgets.Button.on_clicked btn) on_click;
    Widgets.Widget.as_widget btn
  )

let button_s ?icon ?style ?enabled_s ?on_click s =
  Widget (fun ~parent ->
    let btn = Widgets.Button.create ~text:(State.get s) ?parent () in
    Option.iter (Widgets.Button.set_icon btn) icon;
    Option.iter (Widgets.Widget.set_style_sheet btn) style;
    Option.iter (fun es -> State.subscribe es (Widgets.Widget.set_enabled btn)) enabled_s;
    Option.iter (Widgets.Button.on_clicked btn) on_click;
    State.subscribe s (Widgets.Button.set_text btn);
    Widgets.Widget.as_widget btn
  )

let check_box ?checked ?on_toggled text =
  Widget (fun ~parent ->
    let cb = Widgets.CheckBox.create ~text ?parent () in
    Option.iter (fun s ->
      Widgets.CheckBox.set_checked cb (State.get s);
      State.subscribe s (fun b ->
        if Widgets.CheckBox.is_checked cb <> b then Widgets.CheckBox.set_checked cb b);
      Widgets.CheckBox.on_toggled cb (fun b ->
        if State.get s <> b then State.set s b)
    ) checked;
    Option.iter (Widgets.CheckBox.on_toggled cb) on_toggled;
    Widgets.Widget.as_widget cb
  )

let radio_button ?checked ?on_toggled text =
  Widget (fun ~parent ->
    let rb = Widgets.RadioButton.create ~text ?parent () in
    Option.iter (fun s ->
      Widgets.RadioButton.set_checked rb (State.get s);
      State.subscribe s (fun b ->
        if Widgets.RadioButton.is_checked rb <> b then Widgets.RadioButton.set_checked rb b);
      Widgets.RadioButton.on_toggled rb (fun b ->
        if State.get s <> b then State.set s b)
    ) checked;
    Option.iter (Widgets.RadioButton.on_toggled rb) on_toggled;
    Widgets.Widget.as_widget rb
  )

let line_edit ?placeholder ?text ?on_change () =
  Widget (fun ~parent ->
    let init_text = Option.map State.get text in
    let edit = Widgets.LineEdit.create ?text:init_text ?parent () in
    Option.iter (Widgets.LineEdit.set_placeholder_text edit) placeholder;
    Option.iter (fun s ->
      State.subscribe s (fun v ->
        if Widgets.LineEdit.text edit <> v then Widgets.LineEdit.set_text edit v);
      Widgets.LineEdit.on_text_changed edit (fun v ->
        if State.get s <> v then State.set s v)
    ) text;
    Option.iter (Widgets.LineEdit.on_text_changed edit) on_change;
    Widgets.Widget.as_widget edit
  )

let text_edit ?(read_only = false) ?style ?text ?on_change () =
  Widget (fun ~parent ->
    let init_text = Option.map State.get text in
    let te = Widgets.TextEdit.create ?text:init_text ?parent () in
    Widgets.TextEdit.set_read_only te read_only;
    Option.iter (Widgets.Widget.set_style_sheet te) style;
    Option.iter (fun s ->
      State.subscribe s (fun v ->
        if Widgets.TextEdit.to_plain_text te <> v then Widgets.TextEdit.set_plain_text te v);
      Widgets.TextEdit.on_text_changed te (fun () ->
        let v = Widgets.TextEdit.to_plain_text te in
        if State.get s <> v then State.set s v)
    ) text;
    Option.iter (fun oc -> Widgets.TextEdit.on_text_changed te (fun () -> oc (Widgets.TextEdit.to_plain_text te))) on_change;
    Widgets.Widget.as_widget te
  )

let slider ?(min = 0) ?(max = 100) ?orientation ?value ?on_change () =
  Widget (fun ~parent ->
    let s = Widgets.Slider.create ?orientation ?parent () in
    Widgets.Slider.set_range s ~min ~max;
    Option.iter (fun st ->
      Widgets.Slider.set_value s (State.get st);
      State.subscribe st (fun v ->
        if Widgets.Slider.value s <> v then Widgets.Slider.set_value s v);
      Widgets.Slider.on_value_changed s (fun v ->
        if State.get st <> v then State.set st v)
    ) value;
    Option.iter (Widgets.Slider.on_value_changed s) on_change;
    Widgets.Widget.as_widget s
  )

let spin_box ?(min = 0) ?(max = 100) ?prefix ?suffix ?value ?on_change () =
  Widget (fun ~parent ->
    let sb = Widgets.SpinBox.create ?parent () in
    Widgets.SpinBox.set_range sb ~min ~max;
    Option.iter (Widgets.SpinBox.set_prefix sb) prefix;
    Option.iter (Widgets.SpinBox.set_suffix sb) suffix;
    Option.iter (fun st ->
      Widgets.SpinBox.set_value sb (State.get st);
      State.subscribe st (fun v ->
        if Widgets.SpinBox.value sb <> v then Widgets.SpinBox.set_value sb v);
      Widgets.SpinBox.on_value_changed sb (fun v ->
        if State.get st <> v then State.set st v)
    ) value;
    Option.iter (Widgets.SpinBox.on_value_changed sb) on_change;
    Widgets.Widget.as_widget sb
  )

let progress_bar ?(min = 0) ?(max = 100) ?value ?format () =
  Widget (fun ~parent ->
    let pb = Widgets.ProgressBar.create ?parent () in
    Widgets.ProgressBar.set_range pb ~min ~max;
    Option.iter (Widgets.ProgressBar.set_format pb) format;
    Option.iter (fun st ->
      Widgets.ProgressBar.set_value pb (State.get st);
      State.subscribe st (Widgets.ProgressBar.set_value pb)
    ) value;
    Widgets.Widget.as_widget pb
  )

let combo_box ~items ?current ?on_change () =
  Widget (fun ~parent ->
    let cb = Widgets.ComboBox.create ?parent () in
    Widgets.ComboBox.add_items cb items;
    Option.iter (fun st ->
      Widgets.ComboBox.set_current_index cb (State.get st);
      State.subscribe st (fun idx ->
        if Widgets.ComboBox.current_index cb <> idx then Widgets.ComboBox.set_current_index cb idx);
      Widgets.ComboBox.on_current_index_changed cb (fun idx ->
        if State.get st <> idx then State.set st idx)
    ) current;
    Option.iter (Widgets.ComboBox.on_current_index_changed cb) on_change;
    Widgets.Widget.as_widget cb
  )

let canvas ?width ?height ~on_paint ?on_mouse_move ?on_mouse_press ?on_mouse_release ?on_key_press () =
  Widget (fun ~parent ->
    let c = Widgets.Canvas.create ?parent () in
    Option.iter (fun w ->
      let h = Option.value height ~default:w in
      Widgets.Widget.resize c ~width:w ~height:h
    ) width;
    Widgets.Canvas.on_paint c on_paint;
    Option.iter (fun f ->
      Widgets.Canvas.set_mouse_tracking c true;
      Widgets.Canvas.on_mouse_move c f
    ) on_mouse_move;
    Option.iter (Widgets.Canvas.on_mouse_press c) on_mouse_press;
    Option.iter (Widgets.Canvas.on_mouse_release c) on_mouse_release;
    Option.iter (Widgets.Canvas.on_key_press c) on_key_press;
    Widgets.Widget.as_widget c
  )

let custom f = Widget f

(** {1 Top-Level Window & Application Runner} *)

let window ?title ?width ?height ?status_bar child_node =
  Widget (fun ~parent ->
    let win = Widgets.MainWindow.create ?parent () in
    let win_w = Widgets.Widget.as_widget win in
    Option.iter (Widgets.Widget.set_window_title win) title;
    (match width, height with
     | Some w, Some h -> Widgets.Widget.resize win ~width:w ~height:h
     | _ -> ());
    Option.iter (fun sb_state ->
      let sb = Widgets.MainWindow.status_bar win in
      State.subscribe sb_state (Widgets.StatusBar.show_message sb)
    ) status_bar;
    (match child_node with
     | Widget f ->
       let central = f ~parent:(Some win_w) in
       Widgets.MainWindow.set_central_widget win central
     | _ -> ());
    win_w
  )

let mount ?parent node =
  match node with
  | Widget f -> f ~parent
  | Spacing _ | Stretch _ ->
    let w = Widgets.Widget.create ?parent () in
    w

let run ?args ?title ?width ?height node =
  let app = Widgets.App.create ?args () in
  let w = mount node in
  Option.iter (Widgets.Widget.set_window_title w) title;
  (match width, height with
   | Some width, Some height -> Widgets.Widget.resize w ~width ~height
   | _ -> ());
  Widgets.Widget.show w;
  Widgets.App.exec app
