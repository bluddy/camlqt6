module Color = struct
  type t

  external rgb_raw : int -> int -> int -> int option -> t = "caml_oqt6_qcolor_rgb"
  external name : string -> t = "caml_oqt6_qcolor_name"

  let rgb r g b ?alpha () = rgb_raw r g b alpha

  external red : t -> int = "caml_oqt6_qcolor_red"
  external green : t -> int = "caml_oqt6_qcolor_green"
  external blue : t -> int = "caml_oqt6_qcolor_blue"
  external alpha : t -> int = "caml_oqt6_qcolor_alpha"

  let black = rgb 0 0 0 ()
  let white = rgb 255 255 255 ()
  let red_color = rgb 255 0 0 ()
  let green_color = rgb 0 255 0 ()
  let blue_color = rgb 0 0 255 ()
  let yellow = rgb 255 255 0 ()
  let cyan = rgb 0 255 255 ()
  let magenta = rgb 255 0 255 ()
  let gray = rgb 128 128 128 ()
  let light_gray = rgb 192 192 192 ()
  let dark_gray = rgb 64 64 64 ()
  let transparent = rgb 0 0 0 ~alpha:0 ()
end

module Font = struct
  type t

  external create_raw : string option -> int option -> bool option -> bool option -> t = "caml_oqt6_qfont_create"

  let create ?family ?point_size ?bold ?italic () =
    create_raw family point_size bold italic

  external family : t -> string = "caml_oqt6_qfont_family"
  external set_family : t -> string -> unit = "caml_oqt6_qfont_set_family"
  external point_size : t -> int = "caml_oqt6_qfont_point_size"
  external set_point_size : t -> int -> unit = "caml_oqt6_qfont_set_point_size"
  external bold : t -> bool = "caml_oqt6_qfont_bold"
  external set_bold : t -> bool -> unit = "caml_oqt6_qfont_set_bold"
  external italic : t -> bool = "caml_oqt6_qfont_italic"
  external set_italic : t -> bool -> unit = "caml_oqt6_qfont_set_italic"
end

module Pen = struct
  type t
  type style = [ `Solid_line | `Dash_line | `Dot_line | `No_pen ]

  let int_of_style = function
    | `Solid_line -> 0
    | `Dash_line -> 1
    | `Dot_line -> 2
    | `No_pen -> 3

  external create_raw : Color.t option -> int option -> int option -> t = "caml_oqt6_qpen_create"

  let create ?color ?width ?style () =
    create_raw color width (Option.map int_of_style style)

  external set_color : t -> Color.t -> unit = "caml_oqt6_qpen_set_color"
  external set_width : t -> int -> unit = "caml_oqt6_qpen_set_width"
  external set_style_raw : t -> int -> unit = "caml_oqt6_qpen_set_style"

  let set_style p s = set_style_raw p (int_of_style s)
end

module Brush = struct
  type t
  type style = [ `Solid_pattern | `No_brush ]

  let int_of_style = function
    | `Solid_pattern -> 0
    | `No_brush -> 1

  external create_raw : Color.t option -> int option -> t = "caml_oqt6_qbrush_create"

  let create ?color ?style () =
    create_raw color (Option.map int_of_style style)

  external set_color : t -> Color.t -> unit = "caml_oqt6_qbrush_set_color"
  external set_style_raw : t -> int -> unit = "caml_oqt6_qbrush_set_style"

  let set_style b s = set_style_raw b (int_of_style s)
end

module Painter = struct
  type t

  external set_pen : t -> Pen.t -> unit = "caml_oqt6_qpainter_set_pen"
  external set_brush : t -> Brush.t -> unit = "caml_oqt6_qpainter_set_brush"
  external set_font : t -> Font.t -> unit = "caml_oqt6_qpainter_set_font"

  external draw_line_raw : t -> int -> int -> int -> int -> unit = "caml_oqt6_qpainter_draw_line"
  let draw_line p ~x1 ~y1 ~x2 ~y2 = draw_line_raw p x1 y1 x2 y2

  external draw_rect_raw : t -> int -> int -> int -> int -> unit = "caml_oqt6_qpainter_draw_rect"
  let draw_rect p ~x ~y ~width ~height = draw_rect_raw p x y width height

  external fill_rect_raw : t -> int -> int -> int -> int -> Color.t -> unit = "caml_oqt6_qpainter_fill_rect_byte" "caml_oqt6_qpainter_fill_rect"
  let fill_rect p ~x ~y ~width ~height c = fill_rect_raw p x y width height c

  external draw_rounded_rect_raw : t -> int -> int -> int -> int -> float -> float -> unit = "caml_oqt6_qpainter_draw_rounded_rect_byte" "caml_oqt6_qpainter_draw_rounded_rect"
  let draw_rounded_rect p ~x ~y ~width ~height ~x_radius ~y_radius = draw_rounded_rect_raw p x y width height x_radius y_radius

  external draw_ellipse_raw : t -> int -> int -> int -> int -> unit = "caml_oqt6_qpainter_draw_ellipse"
  let draw_ellipse p ~x ~y ~width ~height = draw_ellipse_raw p x y width height

  external draw_text_raw : t -> int -> int -> string -> unit = "caml_oqt6_qpainter_draw_text"
  let draw_text p ~x ~y text = draw_text_raw p x y text

  external save : t -> unit = "caml_oqt6_qpainter_save"
  external restore : t -> unit = "caml_oqt6_qpainter_restore"

  external translate_raw : t -> float -> float -> unit = "caml_oqt6_qpainter_translate"
  let translate p ~dx ~dy = translate_raw p dx dy

  external scale_raw : t -> float -> float -> unit = "caml_oqt6_qpainter_scale"
  let scale p ~sx ~sy = scale_raw p sx sy

  external rotate_raw : t -> float -> unit = "caml_oqt6_qpainter_rotate"
  let rotate p ~angle = rotate_raw p angle
end
