type qwidget = [ Core.qobject | `QWidget ]
type qlayout = [ Core.qobject | `QLayout ]
type qbox_layout = [ qlayout | `QBoxLayout ]
type qvbox_layout = [ qbox_layout | `QVBoxLayout ]
type qhbox_layout = [ qbox_layout | `QHBoxLayout ]
type qpush_button = [ qwidget | `QPushButton ]
type qlabel = [ qwidget | `QLabel ]
type qline_edit = [ qwidget | `QLineEdit ]
type qapplication = [ Core.qobject | `QApplication ]

(* Application *)
external qapp_create : string array option -> qapplication Core.t = "caml_oqt6_qapplication_create"
external qapp_exec : 'a Core.t -> int = "caml_oqt6_qapplication_exec"
external qapp_process_events : unit -> unit = "caml_oqt6_qapplication_process_events"
external qapp_quit : unit -> unit = "caml_oqt6_qapplication_quit"

module App = struct
  let create ?args () = qapp_create args
  let exec = qapp_exec
  let process_events = qapp_process_events
  let quit = qapp_quit
end

(* Widget *)
external qwidget_create : 'a Core.t option -> qwidget Core.t = "caml_oqt6_qwidget_create"
external qwidget_show : 'a Core.t -> unit = "caml_oqt6_qwidget_show"
external qwidget_hide : 'a Core.t -> unit = "caml_oqt6_qwidget_hide"
external qwidget_close : 'a Core.t -> bool = "caml_oqt6_qwidget_close"
external qwidget_set_window_title : 'a Core.t -> string -> unit = "caml_oqt6_qwidget_set_window_title"
external qwidget_window_title : 'a Core.t -> string = "caml_oqt6_qwidget_window_title"
external qwidget_resize : 'a Core.t -> int -> int -> unit = "caml_oqt6_qwidget_resize"
external qwidget_set_fixed_size : 'a Core.t -> int -> int -> unit = "caml_oqt6_qwidget_set_fixed_size"
external qwidget_width : 'a Core.t -> int = "caml_oqt6_qwidget_width"
external qwidget_height : 'a Core.t -> int = "caml_oqt6_qwidget_height"
external qwidget_set_enabled : 'a Core.t -> bool -> unit = "caml_oqt6_qwidget_set_enabled"
external qwidget_is_enabled : 'a Core.t -> bool = "caml_oqt6_qwidget_is_enabled"
external qwidget_set_visible : 'a Core.t -> bool -> unit = "caml_oqt6_qwidget_set_visible"
external qwidget_is_visible : 'a Core.t -> bool = "caml_oqt6_qwidget_is_visible"
external qwidget_set_layout : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qwidget_set_layout"
external qwidget_set_style_sheet : 'a Core.t -> string -> unit = "caml_oqt6_qwidget_set_style_sheet"

module Widget = struct
  let create ?parent () = qwidget_create parent
  let show = qwidget_show
  let hide = qwidget_hide
  let close = qwidget_close
  let set_window_title = qwidget_set_window_title
  let window_title = qwidget_window_title
  let resize w ~width ~height = qwidget_resize w width height
  let set_fixed_size w ~width ~height = qwidget_set_fixed_size w width height
  let width = qwidget_width
  let height = qwidget_height
  let set_enabled = qwidget_set_enabled
  let is_enabled = qwidget_is_enabled
  let set_visible = qwidget_set_visible
  let is_visible = qwidget_is_visible
  let set_layout = qwidget_set_layout
  let set_style_sheet = qwidget_set_style_sheet
end

(* Button *)
external qpushbutton_create : string option -> 'a Core.t option -> qpush_button Core.t = "caml_oqt6_qpushbutton_create"
external qpushbutton_set_text : 'a Core.t -> string -> unit = "caml_oqt6_qpushbutton_set_text"
external qpushbutton_text : 'a Core.t -> string = "caml_oqt6_qpushbutton_text"
external qpushbutton_connect_clicked : 'a Core.t -> (unit -> unit) -> unit = "caml_oqt6_qpushbutton_connect_clicked"

module Button = struct
  let create ?text ?parent () = qpushbutton_create text parent
  let set_text = qpushbutton_set_text
  let text = qpushbutton_text
  let on_clicked = qpushbutton_connect_clicked
end

(* Label *)
external qlabel_create : string option -> 'a Core.t option -> qlabel Core.t = "caml_oqt6_qlabel_create"
external qlabel_set_text : 'a Core.t -> string -> unit = "caml_oqt6_qlabel_set_text"
external qlabel_text : 'a Core.t -> string = "caml_oqt6_qlabel_text"
external qlabel_set_word_wrap : 'a Core.t -> bool -> unit = "caml_oqt6_qlabel_set_word_wrap"

module Label = struct
  let create ?text ?parent () = qlabel_create text parent
  let set_text = qlabel_set_text
  let text = qlabel_text
  let set_word_wrap = qlabel_set_word_wrap
end

(* LineEdit *)
external qlineedit_create : string option -> 'a Core.t option -> qline_edit Core.t = "caml_oqt6_qlineedit_create"
external qlineedit_set_text : 'a Core.t -> string -> unit = "caml_oqt6_qlineedit_set_text"
external qlineedit_text : 'a Core.t -> string = "caml_oqt6_qlineedit_text"
external qlineedit_set_placeholder_text : 'a Core.t -> string -> unit = "caml_oqt6_qlineedit_set_placeholder_text"
external qlineedit_placeholder_text : 'a Core.t -> string = "caml_oqt6_qlineedit_placeholder_text"
external qlineedit_connect_text_changed : 'a Core.t -> (string -> unit) -> unit = "caml_oqt6_qlineedit_connect_text_changed"
external qlineedit_connect_return_pressed : 'a Core.t -> (unit -> unit) -> unit = "caml_oqt6_qlineedit_connect_return_pressed"

module LineEdit = struct
  let create ?text ?parent () = qlineedit_create text parent
  let set_text = qlineedit_set_text
  let text = qlineedit_text
  let set_placeholder_text = qlineedit_set_placeholder_text
  let placeholder_text = qlineedit_placeholder_text
  let on_text_changed = qlineedit_connect_text_changed
  let on_return_pressed = qlineedit_connect_return_pressed
end

(* Layout *)
external qvboxlayout_create : 'a Core.t option -> qvbox_layout Core.t = "caml_oqt6_qvboxlayout_create"
external qhboxlayout_create : 'a Core.t option -> qhbox_layout Core.t = "caml_oqt6_qhboxlayout_create"
external qboxlayout_add_widget : 'a Core.t -> int option -> 'b Core.t -> unit = "caml_oqt6_qboxlayout_add_widget"
external qboxlayout_add_layout : 'a Core.t -> int option -> 'b Core.t -> unit = "caml_oqt6_qboxlayout_add_layout"
external qboxlayout_add_stretch : 'a Core.t -> int option -> unit = "caml_oqt6_qboxlayout_add_stretch"
external qboxlayout_add_spacing : 'a Core.t -> int -> unit = "caml_oqt6_qboxlayout_add_spacing"

module Layout = struct
  module VBox = struct
    let create ?parent () = qvboxlayout_create parent
  end

  module HBox = struct
    let create ?parent () = qhboxlayout_create parent
  end

  let add_widget l ?stretch w = qboxlayout_add_widget l stretch w
  let add_layout l ?stretch sub = qboxlayout_add_layout l stretch sub
  let add_stretch l ?stretch () = qboxlayout_add_stretch l stretch
  let add_spacing = qboxlayout_add_spacing
end
