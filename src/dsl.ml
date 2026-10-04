(** CamlQt6 DSL: Declarative and Reactive UI Framework for Qt 6 *)

module State = struct
  type subscription = int

  type 'a listener = {
    id : int;
    cb : 'a -> unit;
  }

  type 'a t = {
    mutex : Mutex.t;
    eq : 'a -> 'a -> bool;
    mutable value : 'a;
    mutable listeners : 'a listener list;
    mutable next_id : int;
  }

  (** [create ?eq initial] creates a reactive value holding [initial].

      [eq] decides whether a new value counts as a change and is used to suppress
      redundant notifications. It defaults to polymorphic equality, which is
      wrong for some values and must be overridden for others:

      - [nan]: [( <> ) nan nan] is true, so every write notifies.
      - values containing functions: [=] is always false, so every write notifies.
      - cyclic values: [=] diverges.
      - large values: the comparison is deep and runs on every write.

      Pass [Float.equal], or a domain-specific comparator, in those cases. *)
  let create ?(eq = ( = )) initial = {
    mutex = Mutex.create ();
    eq;
    value = initial;
    listeners = [];
    next_id = 0;
  }

  let get s =
    Mutex.lock s.mutex;
    let v = s.value in
    Mutex.unlock s.mutex;
    v

  let set s new_val =
    let to_notify =
      Mutex.lock s.mutex;
      if not (s.eq s.value new_val) then begin
        s.value <- new_val;
        let cbs = List.map (fun l -> l.cb) s.listeners in
        Mutex.unlock s.mutex;
        Some cbs
      end else begin
        Mutex.unlock s.mutex;
        None
      end
    in
    match to_notify with
    | Some cbs -> List.iter (fun f -> f new_val) cbs
    | None -> ()

  let update s f =
    let to_notify, new_val =
      Mutex.lock s.mutex;
      let v = f s.value in
      if not (s.eq s.value v) then begin
        s.value <- v;
        let cbs = List.map (fun l -> l.cb) s.listeners in
        Mutex.unlock s.mutex;
        (Some cbs, v)
      end else begin
        Mutex.unlock s.mutex;
        (None, v)
      end
    in
    match to_notify with
    | Some cbs -> List.iter (fun cb -> cb new_val) cbs
    | None -> ()

  let subscribe_handle s f =
    Mutex.lock s.mutex;
    let id = s.next_id in
    s.next_id <- s.next_id + 1;
    s.listeners <- { id; cb = f } :: s.listeners;
    let cur = s.value in
    Mutex.unlock s.mutex;
    f cur;
    id

  let unsubscribe s id =
    Mutex.lock s.mutex;
    s.listeners <- List.filter (fun l -> l.id <> id) s.listeners;
    Mutex.unlock s.mutex

  let subscribe s f =
    let _ = subscribe_handle s f in
    ()

  (** [map ?eq f src] is a state holding [f (State.get src)], updated whenever
      [src] changes.

      The subscription is permanent: [src] keeps this derived state alive for as
      long as [src] itself. [unsubscribe] cannot reach it because its handle is
      not returned. *)
  let map ?eq f src =
    let derived = create ?eq (f (get src)) in
    let _ = subscribe_handle src (fun v -> set derived (f v)) in
    derived

  (** [map2 ?eq f s1 s2] is a state derived from two states. See {!map} for the
      subscription lifetime caveat. *)
  let map2 ?eq f s1 s2 =
    let derived = create ?eq (f (get s1) (get s2)) in
    let update () = set derived (f (get s1) (get s2)) in
    let _ = subscribe_handle s1 (fun _ -> update ()) in
    let _ = subscribe_handle s2 (fun _ -> update ()) in
    derived
end

let bind_ui (type a) (w : a Core.t) (s : 'b State.t) (update : a Core.t -> 'b -> unit) =
  let obj : Core.qobject Core.t = Core.Internal.cast w in
  let sub = State.subscribe_handle s (fun v ->
    Widgets.App.run_on_ui_thread (fun () ->
      if Core.Object.is_valid obj then
        update w v
    )
  ) in
  Core.Object.on_destroyed obj (fun () -> State.unsubscribe s sub)

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
      bind_ui gb s (fun g b ->
        if Widgets.GroupBox.is_checked g <> b then Widgets.GroupBox.set_checked g b);
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
    bind_ui sw state (fun w idx ->
      if idx >= 0 && idx < count then
        Widgets.StackedWidget.set_current_index w idx
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
    bind_ui lbl s Widgets.Label.set_text;
    Widgets.Widget.as_widget lbl
  )

let button ?icon ?style ?enabled_s ?on_click text =
  Widget (fun ~parent ->
    let btn = Widgets.Button.create ~text ?parent () in
    Option.iter (Widgets.Button.set_icon btn) icon;
    Option.iter (Widgets.Widget.set_style_sheet btn) style;
    Option.iter (fun s -> bind_ui btn s Widgets.Widget.set_enabled) enabled_s;
    Option.iter (Widgets.Button.on_clicked btn) on_click;
    Widgets.Widget.as_widget btn
  )

let button_s ?icon ?style ?enabled_s ?on_click s =
  Widget (fun ~parent ->
    let btn = Widgets.Button.create ~text:(State.get s) ?parent () in
    Option.iter (Widgets.Button.set_icon btn) icon;
    Option.iter (Widgets.Widget.set_style_sheet btn) style;
    Option.iter (fun es -> bind_ui btn es Widgets.Widget.set_enabled) enabled_s;
    Option.iter (Widgets.Button.on_clicked btn) on_click;
    bind_ui btn s Widgets.Button.set_text;
    Widgets.Widget.as_widget btn
  )

let check_box ?checked ?on_toggled text =
  Widget (fun ~parent ->
    let cb = Widgets.CheckBox.create ~text ?parent () in
    Option.iter (fun s ->
      bind_ui cb s (fun w b ->
        if Widgets.CheckBox.is_checked w <> b then Widgets.CheckBox.set_checked w b);
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
      bind_ui rb s (fun w b ->
        if Widgets.RadioButton.is_checked w <> b then Widgets.RadioButton.set_checked w b);
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
      bind_ui edit s (fun w v ->
        if Widgets.LineEdit.text w <> v then Widgets.LineEdit.set_text w v);
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
      bind_ui te s (fun w v ->
        if Widgets.TextEdit.to_plain_text w <> v then Widgets.TextEdit.set_plain_text w v);
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
      bind_ui s st (fun w v ->
        if Widgets.Slider.value w <> v then Widgets.Slider.set_value w v);
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
      bind_ui sb st (fun w v ->
        if Widgets.SpinBox.value w <> v then Widgets.SpinBox.set_value w v);
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
      bind_ui pb st Widgets.ProgressBar.set_value
    ) value;
    Widgets.Widget.as_widget pb
  )

let combo_box ~items ?current ?on_change () =
  Widget (fun ~parent ->
    let cb = Widgets.ComboBox.create ?parent () in
    Widgets.ComboBox.add_items cb items;
    Option.iter (fun st ->
      bind_ui cb st (fun w idx ->
        if Widgets.ComboBox.current_index w <> idx then Widgets.ComboBox.set_current_index w idx);
      Widgets.ComboBox.on_current_index_changed cb (fun idx ->
        if State.get st <> idx then State.set st idx)
    ) current;
    Option.iter (Widgets.ComboBox.on_current_index_changed cb) on_change;
    Widgets.Widget.as_widget cb
  )

let canvas ?width ?height ?(antialiasing = true) ~on_paint ?on_mouse_move
    ?on_mouse_press ?on_mouse_release ?on_key_press () =
  Widget (fun ~parent ->
    let c = Widgets.Canvas.create ?parent () in
    (* Set the hint on the painter rather than in on_paint, so the OCaml closure
       only has to draw. The painter is invalid here, so this is applied lazily
       inside the first paint via a wrapper closure. *)
    let on_paint painter =
      if antialiasing then Gui.Painter.enable_antialiasing painter;
      on_paint painter
    in
    (match width with
     | Some w ->
       let h = Option.value height ~default:w in
       Widgets.Widget.resize c ~width:w ~height:h
     | None -> Option.iter (fun h -> Widgets.Widget.resize c ~width:100 ~height:h) height);
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
      bind_ui sb sb_state (fun s msg -> Widgets.StatusBar.show_message s msg)
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
