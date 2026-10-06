(** Qt 6 GUI module (fonts, colors, pens, brushes, painters, pixmaps, icons, cursors) *)

module Color : sig
  type t

  val rgb : int -> int -> int -> ?alpha:int -> unit -> t

  (** [name "red"] parses a Qt colour name or any format [QColor] understands.

      @raise Invalid_argument if the string is not a valid colour. Use [of_hex]
      or [of_hsv] for programmatic construction. *)
  val name : string -> t

  val red : t -> int
  val green : t -> int
  val blue : t -> int
  val alpha : t -> int
  val is_valid : t -> bool

  (** "#AARRGGBB". *)
  val to_hex : t -> string

  (** [lighter 150] is 50% lighter; [lighter (-50)] is darker. *)
  val lighter : t -> int -> t

  (** [darker 150] is 50% darker. *)
  val darker : t -> int -> t

  (** [(hue 0-359, saturation 0-255, value 0-255)]. *)
  val hsv : t -> int * int * int

  (** [(hue 0-359, saturation 0-255, lightness 0-255)]. *)
  val hsl : t -> int * int * int

  val of_hsv : int -> int -> int -> t
  val of_hsl : int -> int -> int -> t

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

  val create :
    ?family:string ->
    ?point_size:int ->
    ?bold:bool ->
    ?italic:bool ->
    ?weight:int ->
    ?underline:bool ->
    ?strikeout:bool ->
    ?letter_spacing:float ->
    unit -> t

  val family : t -> string
  val set_family : t -> string -> unit
  val point_size : t -> int
  val set_point_size : t -> int -> unit
  val point_size_f : t -> float
  val bold : t -> bool
  val set_bold : t -> bool -> unit
  val italic : t -> bool
  val set_italic : t -> bool -> unit

  (** QFont::Weight, 0-1000. Use the constants below. *)
  val weight : t -> int
  val set_weight : t -> int -> unit

  val underline : t -> bool
  val set_underline : t -> bool -> unit
  val strikeout : t -> bool
  val set_strikeout : t -> bool -> unit

  (** Absolute spacing in pixels. *)
  val letter_spacing : t -> float
  val set_letter_spacing : t -> float -> unit

  val thin : int
  val extra_light : int
  val light : int
  val normal : int
  val medium : int
  val demi_bold : int
  val bold_weight : int
  val extra_bold : int
  val black_weight : int
end

module Pen : sig
  type t

  type style =
    [ `Solid_line | `Dash_line | `Dot_line | `No_pen | `Dash_dot_line
    | `Dash_dot_dot_line ]

  type cap_style = [ `Round_cap | `Flat_cap | `Square_cap ]
  type join_style = [ `Round_join | `Bevel_join | `Miter_join ]

  val create : ?color:Color.t -> ?width:int -> ?style:style -> unit -> t
  val set_color : t -> Color.t -> unit
  val set_width : t -> int -> unit
  val set_style : t -> style -> unit
  val set_cap_style : t -> cap_style -> unit
  val set_join_style : t -> join_style -> unit

  (** Dash lengths in units of the pen width; an empty list means a solid line. *)
  val set_dash_pattern : t -> float list -> unit

  val color : t -> Color.t
  val width : t -> int
  val style : t -> style
  val cap_style : t -> cap_style
  val join_style : t -> join_style
end

module Brush : sig
  type t

  type style =
    [ `Solid_pattern | `No_brush | `Dense5_pattern | `Dense7_pattern
    | `Cross_pattern | `Ver_pattern | `Hor_pattern ]

  val create : ?color:Color.t -> ?style:style -> unit -> t
  val set_color : t -> Color.t -> unit
  val set_style : t -> style -> unit
  val color : t -> Color.t
  val style : t -> style
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

  (** [is_null icon] is true only when Qt itself reports the icon as null. Do
      **not** use it to check that a file loaded: on Linux,
      [QIcon "missing.png"] constructs a loader engine entry anyway and reports
      [isNull ()] = [false], while on Windows it reports [true]. Use
      {!available_sizes} to find out whether an icon is actually usable. *)
  val is_null : t -> bool

  (** The sizes this icon can actually be rendered at, as [(width, height)]. Empty
      means nothing loaded: the file is missing, the format is unsupported, or
      the theme lookup failed. This is the portable "did it work?" check, unlike
      {!is_null}. *)
  val available_sizes : t -> (int * int) list
end

module Painter : sig
  type t

  (** Rendering quality hints. These are off by default in Qt, which is why
      hand-drawn output looks jagged until [Antialiasing] is enabled. *)
  type render_hint =
    [ `Antialiasing | `Text_antialiasing | `Smooth_pixmap_transform ]

  val set_pen : t -> Pen.t -> unit
  val set_brush : t -> Brush.t -> unit
  val set_font : t -> Font.t -> unit

  (** [set_render_hint p `Antialiasing true] smooths shape edges,
      [`Text_antialiasing] smooths glyphs, and [`Smooth_pixmap_transform]
      smooths scaled pixmaps. *)
  val set_render_hint : t -> render_hint -> bool -> unit

  (** Shorthand for `set_render_hint p h on`. *)
  val set_hint : t -> render_hint -> bool -> unit

  (** Turns on both [`Antialiasing] and [`Text_antialiasing]. *)
  val enable_antialiasing : t -> unit

  (** Brush opacity in [0.0, 1.0]. *)
  val set_opacity : t -> float -> unit

  val draw_line : t -> x1:int -> y1:int -> x2:int -> y2:int -> unit
  val draw_rect : t -> x:int -> y:int -> width:int -> height:int -> unit
  val fill_rect : t -> x:int -> y:int -> width:int -> height:int -> Color.t -> unit

  (** Fill using the current brush instead of an explicit colour. *)
  val fill_rect_brush : t -> x:int -> y:int -> width:int -> height:int -> unit

  val draw_rounded_rect :
    t -> x:int -> y:int -> width:int -> height:int -> x_radius:float -> y_radius:float -> unit
  val draw_ellipse : t -> x:int -> y:int -> width:int -> height:int -> unit
  val draw_text : t -> x:int -> y:int -> string -> unit
  val draw_pixmap : t -> x:int -> y:int -> Pixmap.t -> unit

  (** Points are [(x, y)] float pairs, so sub-pixel placement is possible. Fewer
      than two points draws nothing. *)
  val draw_polyline : t -> (float * float) list -> unit
  val draw_polygon : t -> (float * float) list -> unit

  (** Angles are in degrees, counter-clockwise from 3 o'clock; [span_deg] may be
      negative. [rect] is [(x, y, width, height)]. *)
  val draw_arc_deg : t -> rect:(int * int * int * int) -> start_deg:float -> span_deg:float -> unit
  val draw_pie_deg : t -> rect:(int * int * int * int) -> start_deg:float -> span_deg:float -> unit

  (** Bounding box of [text] in the painter's current font, as
      [(x, y, width, height)]. *)
  val bounding_rect : t -> string -> int * int * int * int

  val save : t -> unit
  val restore : t -> unit
  val translate : t -> dx:float -> dy:float -> unit
  val scale : t -> sx:float -> sy:float -> unit

  (** Degrees, counter-clockwise. *)
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
