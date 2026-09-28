(** Qt 6 GUI module (fonts, colors, pens, brushes, painters) *)

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

  val save : t -> unit
  val restore : t -> unit
  val translate : t -> dx:float -> dy:float -> unit
  val scale : t -> sx:float -> sy:float -> unit
  val rotate : t -> angle:float -> unit
end
