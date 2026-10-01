(** Qt 6 GUI module (fonts, colors, pens, brushes, painters, pixmaps, icons, cursors) *)

module Color : sig
  type t

  val rgb : int -> int -> int -> ?alpha:int -> unit -> t
  val name : string -> t

  val red : t -> int
  val green : t -> int
  val blue : t -> int
  val alpha : t -> int

  val black : t
  val white : t
  val red_color : t
  val green_color : t
  val blue_color : t
  val yellow : t
  val cyan : t
  val magenta : t
  val gray : t
  val light_gray : t
  val dark_gray : t
  val transparent : t
end

module Font : sig
  type t

  val create : ?family:string -> ?point_size:int -> ?bold:bool -> ?italic:bool -> unit -> t
  val family : t -> string
  val set_family : t -> string -> unit
  val point_size : t -> int
  val set_point_size : t -> int -> unit
  val bold : t -> bool
  val set_bold : t -> bool -> unit
  val italic : t -> bool
  val set_italic : t -> bool -> unit
end

module Pen : sig
  type t
  type style = [ `Solid_line | `Dash_line | `Dot_line | `No_pen ]

  val create : ?color:Color.t -> ?width:int -> ?style:style -> unit -> t
  val set_color : t -> Color.t -> unit
  val set_width : t -> int -> unit
  val set_style : t -> style -> unit
end

module Brush : sig
  type t
  type style = [ `Solid_pattern | `No_brush ]

  val create : ?color:Color.t -> ?style:style -> unit -> t
  val set_color : t -> Color.t -> unit
  val set_style : t -> style -> unit
end

module Pixmap : sig
  type t

  val create : width:int -> height:int -> t
  val load : string -> t option
  val width : t -> int
  val height : t -> int
  val is_null : t -> bool
  val fill : t -> Color.t -> unit
end

module Icon : sig
  type t

  val from_file : string -> t
  val from_pixmap : Pixmap.t -> t
  val from_theme : string -> t
  val is_null : t -> bool
end

module Painter : sig
  type t

  val set_pen : t -> Pen.t -> unit
  val set_brush : t -> Brush.t -> unit
  val set_font : t -> Font.t -> unit

  val draw_line : t -> x1:int -> y1:int -> x2:int -> y2:int -> unit
  val draw_rect : t -> x:int -> y:int -> width:int -> height:int -> unit
  val fill_rect : t -> x:int -> y:int -> width:int -> height:int -> Color.t -> unit
  val draw_rounded_rect : t -> x:int -> y:int -> width:int -> height:int -> x_radius:float -> y_radius:float -> unit
  val draw_ellipse : t -> x:int -> y:int -> width:int -> height:int -> unit
  val draw_text : t -> x:int -> y:int -> string -> unit
  val draw_pixmap : t -> x:int -> y:int -> Pixmap.t -> unit

  val save : t -> unit
  val restore : t -> unit
  val translate : t -> dx:float -> dy:float -> unit
  val scale : t -> sx:float -> sy:float -> unit
  val rotate : t -> angle:float -> unit
end

module Cursor : sig
  type shape = [
    | `Arrow
    | `Up_arrow
    | `Cross
    | `Wait
    | `I_beam
    | `Size_ver
    | `Size_hor
    | `Size_bdiag
    | `Size_fdiag
    | `Size_all
    | `Blank
    | `Split_v
    | `Split_h
    | `Pointing_hand
    | `Forbidden
    | `Open_hand
    | `Closed_hand
  ]

  val set_cursor : [> `QWidget ] Core.t -> shape -> unit
  val unset_cursor : [> `QWidget ] Core.t -> unit
end

module MimeData : sig
  type qmimedata = Core.qmimedata
  type t = qmimedata Core.t

  val create : unit -> t
  val text : [> `QMimeData ] Core.t -> string option
  val set_text : [> `QMimeData ] Core.t -> string -> unit
  val has_text : [> `QMimeData ] Core.t -> bool
  val urls : [> `QMimeData ] Core.t -> string list
  val set_urls : [> `QMimeData ] Core.t -> string list -> unit
  val has_urls : [> `QMimeData ] Core.t -> bool
  val html : [> `QMimeData ] Core.t -> string option
  val set_html : [> `QMimeData ] Core.t -> string -> unit
  val has_html : [> `QMimeData ] Core.t -> bool
  val formats : [> `QMimeData ] Core.t -> string list
  val data : [> `QMimeData ] Core.t -> string -> string option
  val set_data : [> `QMimeData ] Core.t -> string -> string -> unit
  val clear : [> `QMimeData ] Core.t -> unit
end

module Drag : sig
  type qdrag = Core.qdrag
  type t = qdrag Core.t
  type drop_action = [ `Ignore | `Copy | `Move | `Link ]
  type actions_supported = [ `Copy | `Move | `Link | `Copy_or_move ]

  val create : [> `QWidget ] Core.t -> t
  val set_mime_data : [> `QDrag ] Core.t -> [> `QMimeData ] Core.t -> unit
  val mime_data : [> `QDrag ] Core.t -> MimeData.t option
  val set_pixmap : [> `QDrag ] Core.t -> Pixmap.t -> unit
  val set_hot_spot : [> `QDrag ] Core.t -> x:int -> y:int -> unit
  val exec : ?actions:actions_supported -> [> `QDrag ] Core.t -> drop_action
end

module Clipboard : sig
  type mode = [ `Clipboard | `Selection | `Find_buffer ]

  val text : ?mode:mode -> unit -> string option
  val set_text : ?mode:mode -> string -> unit
  val pixmap : ?mode:mode -> unit -> Pixmap.t option
  val set_pixmap : ?mode:mode -> Pixmap.t -> unit
  val mime_data : ?mode:mode -> unit -> MimeData.t option
  val set_mime_data : ?mode:mode -> [> `QMimeData ] Core.t -> unit
  val clear : ?mode:mode -> unit -> unit
  val on_changed : (unit -> unit) -> unit
end
