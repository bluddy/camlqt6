(** Qt 6 Widgets module *)

type qwidget = [ Core.qobject | `QWidget ]
type qlayout = [ Core.qobject | `QLayout ]
type qbox_layout = [ qlayout | `QBoxLayout ]
type qvbox_layout = [ qbox_layout | `QVBoxLayout ]
type qhbox_layout = [ qbox_layout | `QHBoxLayout ]
type qpush_button = [ qwidget | `QPushButton ]
type qlabel = [ qwidget | `QLabel ]
type qline_edit = [ qwidget | `QLineEdit ]
type qapplication = [ Core.qobject | `QApplication ]

module App : sig
  val create : ?args:string array -> unit -> qapplication Core.t
  val exec : qapplication Core.t -> int
  val process_events : unit -> unit
  val quit : unit -> unit
end

module Widget : sig
  val create : ?parent:[> `QWidget ] Core.t -> unit -> qwidget Core.t
  val show : [> `QWidget ] Core.t -> unit
  val hide : [> `QWidget ] Core.t -> unit
  val close : [> `QWidget ] Core.t -> bool
  val set_window_title : [> `QWidget ] Core.t -> string -> unit
  val window_title : [> `QWidget ] Core.t -> string
  val resize : [> `QWidget ] Core.t -> width:int -> height:int -> unit
  val set_fixed_size : [> `QWidget ] Core.t -> width:int -> height:int -> unit
  val width : [> `QWidget ] Core.t -> int
  val height : [> `QWidget ] Core.t -> int
  val set_enabled : [> `QWidget ] Core.t -> bool -> unit
  val is_enabled : [> `QWidget ] Core.t -> bool
  val set_visible : [> `QWidget ] Core.t -> bool -> unit
  val is_visible : [> `QWidget ] Core.t -> bool
  val set_layout : [> `QWidget ] Core.t -> [> `QLayout ] Core.t -> unit
  val set_style_sheet : [> `QWidget ] Core.t -> string -> unit
end

module Button : sig
  val create : ?text:string -> ?parent:[> `QWidget ] Core.t -> unit -> qpush_button Core.t
  val set_text : [> `QPushButton ] Core.t -> string -> unit
  val text : [> `QPushButton ] Core.t -> string
  val on_clicked : [> `QPushButton ] Core.t -> (unit -> unit) -> unit
end

module Label : sig
  val create : ?text:string -> ?parent:[> `QWidget ] Core.t -> unit -> qlabel Core.t
  val set_text : [> `QLabel ] Core.t -> string -> unit
  val text : [> `QLabel ] Core.t -> string
  val set_word_wrap : [> `QLabel ] Core.t -> bool -> unit
end

module LineEdit : sig
  val create : ?text:string -> ?parent:[> `QWidget ] Core.t -> unit -> qline_edit Core.t
  val set_text : [> `QLineEdit ] Core.t -> string -> unit
  val text : [> `QLineEdit ] Core.t -> string
  val set_placeholder_text : [> `QLineEdit ] Core.t -> string -> unit
  val placeholder_text : [> `QLineEdit ] Core.t -> string
  val on_text_changed : [> `QLineEdit ] Core.t -> (string -> unit) -> unit
  val on_return_pressed : [> `QLineEdit ] Core.t -> (unit -> unit) -> unit
end

module Layout : sig
  module VBox : sig
    val create : ?parent:[> `QWidget ] Core.t -> unit -> qvbox_layout Core.t
  end

  module HBox : sig
    val create : ?parent:[> `QWidget ] Core.t -> unit -> qhbox_layout Core.t
  end

  val add_widget : [> `QBoxLayout ] Core.t -> ?stretch:int -> [> `QWidget ] Core.t -> unit
  val add_layout : [> `QBoxLayout ] Core.t -> ?stretch:int -> [> `QLayout ] Core.t -> unit
  val add_stretch : [> `QBoxLayout ] Core.t -> ?stretch:int -> unit -> unit
  val add_spacing : [> `QBoxLayout ] Core.t -> int -> unit
end
