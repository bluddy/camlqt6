module Color = struct
  type t

  external rgb_raw : int -> int -> int -> int option -> t = "caml_oqt6_qcolor_rgb"
  external name_checked : string -> t = "caml_oqt6_qcolor_name_checked"

  (* An unparsable name raises Invalid_argument rather than yielding an invalid
     colour that silently renders as something unexpected. *)
  let name s = name_checked s

  external red : t -> int = "caml_oqt6_qcolor_red"
  external green : t -> int = "caml_oqt6_qcolor_green"
  external blue : t -> int = "caml_oqt6_qcolor_blue"
  external alpha : t -> int = "caml_oqt6_qcolor_alpha"
  external is_valid : t -> bool = "caml_oqt6_qcolor_is_valid"
  external to_hex : t -> string = "caml_oqt6_qcolor_to_hex"
  external lighter : t -> int -> t = "caml_oqt6_qcolor_lighter"
  external darker : t -> int -> t = "caml_oqt6_qcolor_darker"
  external hsv : t -> int * int * int = "caml_oqt6_qcolor_hsv"
  external hsl : t -> int * int * int = "caml_oqt6_qcolor_hsl"
  external of_hsv : int -> int -> int -> t = "caml_oqt6_qcolor_from_hsv"
  external of_hsl : int -> int -> int -> t = "caml_oqt6_qcolor_from_hsl"

  let rgb r g b ?alpha () = rgb_raw r g b alpha
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

  external family : t -> string = "caml_oqt6_qfont_family"
  external set_family : t -> string -> unit = "caml_oqt6_qfont_set_family"
  external point_size : t -> int = "caml_oqt6_qfont_point_size"
  external set_point_size : t -> int -> unit = "caml_oqt6_qfont_set_point_size"
  external bold : t -> bool = "caml_oqt6_qfont_bold"
  external set_bold : t -> bool -> unit = "caml_oqt6_qfont_set_bold"
  external italic : t -> bool = "caml_oqt6_qfont_italic"
  external set_italic : t -> bool -> unit = "caml_oqt6_qfont_set_italic"
  external weight : t -> int = "caml_oqt6_qfont_weight"
  external set_weight : t -> int -> unit = "caml_oqt6_qfont_set_weight"
  external underline : t -> bool = "caml_oqt6_qfont_underline"
  external set_underline : t -> bool -> unit = "caml_oqt6_qfont_set_underline"
  external strikeout : t -> bool = "caml_oqt6_qfont_strikeout"
  external set_strikeout : t -> bool -> unit = "caml_oqt6_qfont_set_strikeout"
  external point_size_f : t -> float = "caml_oqt6_qfont_point_size_f"
  external letter_spacing : t -> float = "caml_oqt6_qfont_letter_spacing"
  external set_letter_spacing : t -> float -> unit = "caml_oqt6_qfont_set_letter_spacing"

  let create ?family ?point_size ?bold ?italic ?weight ?underline ?strikeout
      ?letter_spacing () =
    let f = create_raw family point_size bold italic in
    Option.iter (set_weight f) weight;
    Option.iter (set_underline f) underline;
    Option.iter (set_strikeout f) strikeout;
    Option.iter (set_letter_spacing f) letter_spacing;
    f

  (* QFont::Weight values, as ints to be passed straight to [set_weight].
     [bold_weight] rather than [bold] because [bold] is already the accessor. *)
  let thin = 0
  let extra_light = 12
  let light = 50
  let normal = 75
  let medium = 100
  let demi_bold = 63
  let bold_weight = 75
  let extra_bold = 200
  let black_weight = 300
end

module Pen = struct
  type t

  type style =
    [ `Solid_line | `Dash_line | `Dot_line | `No_pen | `Dash_dot_line | `Dash_dot_dot_line ]

  type cap_style = [ `Round_cap | `Flat_cap | `Square_cap ]
  type join_style = [ `Round_join | `Bevel_join | `Miter_join ]

  let int_of_style = function
    | `Solid_line -> 0
    | `Dash_line -> 1
    | `Dot_line -> 2
    | `No_pen -> 3
    | `Dash_dot_line -> 4
    | `Dash_dot_dot_line -> 5

  let int_of_cap = function `Round_cap -> 0 | `Flat_cap -> 1 | `Square_cap -> 2

  let int_of_join = function `Round_join -> 0 | `Bevel_join -> 1 | `Miter_join -> 2

  external create_raw : Color.t option -> int option -> int option -> t = "caml_oqt6_qpen_create"

  let create ?color ?width ?style () =
    create_raw color width (Option.map int_of_style style)

  external set_color : t -> Color.t -> unit = "caml_oqt6_qpen_set_color"
  external set_width : t -> int -> unit = "caml_oqt6_qpen_set_width"
  external set_style_raw : t -> int -> unit = "caml_oqt6_qpen_set_style"
  external style_raw : t -> int = "caml_oqt6_qpen_style"
  external color : t -> Color.t = "caml_oqt6_qpen_color"
  external width : t -> int = "caml_oqt6_qpen_width"
  external set_cap_style_raw : t -> int -> unit = "caml_oqt6_qpen_set_cap_style"
  external cap_style_raw : t -> int = "caml_oqt6_qpen_cap_style"
  external set_join_style_raw : t -> int -> unit = "caml_oqt6_qpen_set_join_style"
  external join_style_raw : t -> int = "caml_oqt6_qpen_join_style"
  external set_dash_pattern : t -> float list -> unit = "caml_oqt6_qpen_set_dash_pattern"

  let set_style p s = set_style_raw p (int_of_style s)
  let set_cap_style p s = set_cap_style_raw p (int_of_cap s)
  let set_join_style p s = set_join_style_raw p (int_of_join s)

  let style p =
    match style_raw p with
    | 1 -> `Dash_line
    | 2 -> `Dot_line
    | 3 -> `No_pen
    | 4 -> `Dash_dot_line
    | 5 -> `Dash_dot_dot_line
    | _ -> `Solid_line

  let cap_style p =
    match cap_style_raw p with 1 -> `Flat_cap | 2 -> `Square_cap | _ -> `Round_cap

  let join_style p =
    match join_style_raw p with 1 -> `Bevel_join | 2 -> `Miter_join | _ -> `Round_join
end

module Brush = struct
  type t

  type style =
    [ `Solid_pattern | `No_brush | `Dense5_pattern | `Dense7_pattern
    | `Cross_pattern | `Ver_pattern | `Hor_pattern ]

  let int_of_style = function
    | `Solid_pattern -> 0
    | `No_brush -> 1
    | `Dense5_pattern -> 2
    | `Dense7_pattern -> 3
    | `Cross_pattern -> 4
    | `Ver_pattern -> 5
    | `Hor_pattern -> 6

  external create_raw : Color.t option -> int option -> t = "caml_oqt6_qbrush_create"

  let create ?color ?style () =
    create_raw color (Option.map int_of_style style)

  external set_color : t -> Color.t -> unit = "caml_oqt6_qbrush_set_color"
  external set_style_raw : t -> int -> unit = "caml_oqt6_qbrush_set_style"
  external style_raw : t -> int = "caml_oqt6_qbrush_style"
  external color : t -> Color.t = "caml_oqt6_qbrush_color"

  let set_style b s = set_style_raw b (int_of_style s)

  let style b =
    match style_raw b with
    | 1 -> `No_brush
    | 2 -> `Dense5_pattern
    | 3 -> `Dense7_pattern
    | 4 -> `Cross_pattern
    | 5 -> `Ver_pattern
    | 6 -> `Hor_pattern
    | _ -> `Solid_pattern
end

module Pixmap = struct
  type t

  external create_raw : int -> int -> t = "caml_oqt6_qpixmap_create"
  let create ~width ~height = create_raw width height

  external load : string -> t option = "caml_oqt6_qpixmap_load"
  external width : t -> int = "caml_oqt6_qpixmap_width"
  external height : t -> int = "caml_oqt6_qpixmap_height"
  external is_null : t -> bool = "caml_oqt6_qpixmap_is_null"
  external fill : t -> Color.t -> unit = "caml_oqt6_qpixmap_fill"
end

module Icon = struct
  type t

  external from_file : string -> t = "caml_oqt6_qicon_from_file"
  external from_pixmap : Pixmap.t -> t = "caml_oqt6_qicon_from_pixmap"
  external from_theme : string -> t = "caml_oqt6_qicon_from_theme"
  external is_null : t -> bool = "caml_oqt6_qicon_is_null"
end

module Painter = struct
  type t

  (** Rendering quality hints. Without these, every primitive renders with hard
      (aliased) edges, which is why [Antialiasing] is usually the first thing to
      turn on. *)
  type render_hint =
    [ `Antialiasing | `Text_antialiasing | `Smooth_pixmap_transform ]

  let int_of_render_hint = function
    | `Antialiasing -> 0
    | `Text_antialiasing -> 1
    | `Smooth_pixmap_transform -> 2

  external set_pen : t -> Pen.t -> unit = "caml_oqt6_qpainter_set_pen"
  external set_brush : t -> Brush.t -> unit = "caml_oqt6_qpainter_set_brush"
  external set_font : t -> Font.t -> unit = "caml_oqt6_qpainter_set_font"
  external set_render_hint_raw : t -> int -> bool -> unit = "caml_oqt6_qpainter_set_render_hint"
  external set_opacity : t -> float -> unit = "caml_oqt6_qpainter_set_opacity"

  (** [set_render_hint p `Antialiasing true] smooths shape edges.
      [`Text_antialiasing] smooths text; [`Smooth_pixmap_transform] scales
      pixmaps smoothly when [draw_pixmap] is given a size. *)
  let set_render_hint p h on = set_render_hint_raw p (int_of_render_hint h) on
  let set_hint = set_render_hint

  (** Convenience for the common case. *)
  let enable_antialiasing p =
    set_render_hint p `Antialiasing true;
    set_render_hint p `Text_antialiasing true

  external draw_line_raw : t -> int -> int -> int -> int -> unit = "caml_oqt6_qpainter_draw_line"
  let draw_line p ~x1 ~y1 ~x2 ~y2 = draw_line_raw p x1 y1 x2 y2

  external draw_rect_raw : t -> int -> int -> int -> int -> unit = "caml_oqt6_qpainter_draw_rect"
  let draw_rect p ~x ~y ~width ~height = draw_rect_raw p x y width height

  external fill_rect_raw : t -> int -> int -> int -> int -> Color.t -> unit = "caml_oqt6_qpainter_fill_rect_byte" "caml_oqt6_qpainter_fill_rect"
  let fill_rect p ~x ~y ~width ~height c = fill_rect_raw p x y width height c

  (** Fill using the current brush rather than an explicit colour. *)
  external fill_rect_with_brush : t -> int -> int -> int -> int -> unit = "caml_oqt6_qpainter_fill_rect_with_brush"
  let fill_rect_brush p ~x ~y ~width ~height = fill_rect_with_brush p x y width height

  external draw_rounded_rect_raw : t -> int -> int -> int -> int -> float -> float -> unit = "caml_oqt6_qpainter_draw_rounded_rect_byte" "caml_oqt6_qpainter_draw_rounded_rect"
  let draw_rounded_rect p ~x ~y ~width ~height ~x_radius ~y_radius = draw_rounded_rect_raw p x y width height x_radius y_radius

  external draw_ellipse_raw : t -> int -> int -> int -> int -> unit = "caml_oqt6_qpainter_draw_ellipse"
  let draw_ellipse p ~x ~y ~width ~height = draw_ellipse_raw p x y width height

  external draw_text_raw : t -> int -> int -> string -> unit = "caml_oqt6_qpainter_draw_text"
  let draw_text p ~x ~y text = draw_text_raw p x y text

  external draw_pixmap_raw : t -> int -> int -> Pixmap.t -> unit = "caml_oqt6_qpainter_draw_pixmap"
  let draw_pixmap p ~x ~y pm = draw_pixmap_raw p x y pm

  (** Points are [(x, y)] pairs of floats, so sub-pixel placement is possible.
      Fewer than two points draws nothing. *)
  external draw_polyline : t -> (float * float) list -> unit = "caml_oqt6_qpainter_draw_polyline"
  external draw_polygon : t -> (float * float) list -> unit = "caml_oqt6_qpainter_draw_polygon"

  (** Angles are in degrees, counter-clockwise from 3 o'clock. [span] may be
      negative. The rectangle is a single [(x, y, width, height)] tuple so the
      binding stays within the 5-argument limit for native stubs. *)
  external draw_arc : t -> (int * int * int * int) -> float -> float -> unit = "caml_oqt6_qpainter_draw_arc"
  external draw_pie : t -> (int * int * int * int) -> float -> float -> unit = "caml_oqt6_qpainter_draw_pie"

  let draw_arc_deg p ~rect ~start_deg ~span_deg =
    draw_arc p rect start_deg span_deg

  let draw_pie_deg p ~rect ~start_deg ~span_deg =
    draw_pie p rect start_deg span_deg

  (** Bounding box of [text] in the painter's current font, as
      [(x, y, width, height)]. *)
  external bounding_rect : t -> string -> int * int * int * int = "caml_oqt6_qpainter_bounding_rect"

  external save : t -> unit = "caml_oqt6_qpainter_save"
  external restore : t -> unit = "caml_oqt6_qpainter_restore"

  external translate_raw : t -> float -> float -> unit = "caml_oqt6_qpainter_translate"
  let translate p ~dx ~dy = translate_raw p dx dy

  external scale_raw : t -> float -> float -> unit = "caml_oqt6_qpainter_scale"
  let scale p ~sx ~sy = scale_raw p sx sy

  external rotate_raw : t -> float -> unit = "caml_oqt6_qpainter_rotate"
  let rotate p ~angle = rotate_raw p angle
end

module Cursor = struct
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

  let int_of_shape = function
    | `Arrow -> 0
    | `Up_arrow -> 1
    | `Cross -> 2
    | `Wait -> 3
    | `I_beam -> 4
    | `Size_ver -> 5
    | `Size_hor -> 6
    | `Size_bdiag -> 7
    | `Size_fdiag -> 8
    | `Size_all -> 9
    | `Blank -> 10
    | `Split_v -> 11
    | `Split_h -> 12
    | `Pointing_hand -> 13
    | `Forbidden -> 14
    | `Open_hand -> 15
    | `Closed_hand -> 16

  external set_cursor_raw : 'a Core.t -> int -> unit = "caml_oqt6_qwidget_set_cursor"
  external unset_cursor : 'a Core.t -> unit = "caml_oqt6_qwidget_unset_cursor"

  let set_cursor w shape = set_cursor_raw w (int_of_shape shape)
end

(* QMimeData *)
external qmimedata_create : unit -> Core.qmimedata Core.t = "caml_oqt6_qmimedata_create"
external qmimedata_has_text : 'a Core.t -> bool = "caml_oqt6_qmimedata_has_text"
external qmimedata_text : 'a Core.t -> string option = "caml_oqt6_qmimedata_text"
external qmimedata_set_text : 'a Core.t -> string -> unit = "caml_oqt6_qmimedata_set_text"
external qmimedata_has_urls : 'a Core.t -> bool = "caml_oqt6_qmimedata_has_urls"
external qmimedata_urls : 'a Core.t -> string list = "caml_oqt6_qmimedata_urls"
external qmimedata_set_urls : 'a Core.t -> string list -> unit = "caml_oqt6_qmimedata_set_urls"
external qmimedata_has_html : 'a Core.t -> bool = "caml_oqt6_qmimedata_has_html"
external qmimedata_html : 'a Core.t -> string option = "caml_oqt6_qmimedata_html"
external qmimedata_set_html : 'a Core.t -> string -> unit = "caml_oqt6_qmimedata_set_html"
external qmimedata_formats : 'a Core.t -> string list = "caml_oqt6_qmimedata_formats"
external qmimedata_data : 'a Core.t -> string -> string option = "caml_oqt6_qmimedata_data"
external qmimedata_set_data : 'a Core.t -> string -> string -> unit = "caml_oqt6_qmimedata_set_data"
external qmimedata_clear : 'a Core.t -> unit = "caml_oqt6_qmimedata_clear"

module MimeData = struct
  type qmimedata = Core.qmimedata
  type t = qmimedata Core.t

  let create () = qmimedata_create ()
  let has_text = qmimedata_has_text
  let text = qmimedata_text
  let set_text = qmimedata_set_text
  let has_urls = qmimedata_has_urls
  let urls = qmimedata_urls
  let set_urls = qmimedata_set_urls
  let has_html = qmimedata_has_html
  let html = qmimedata_html
  let set_html = qmimedata_set_html
  let formats = qmimedata_formats
  let data = qmimedata_data
  let set_data = qmimedata_set_data
  let clear = qmimedata_clear
end

(* QDrag *)
external qdrag_create : 'a Core.t -> Core.qdrag Core.t = "caml_oqt6_qdrag_create"
external qdrag_set_mime_data : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qdrag_set_mime_data"
external qdrag_mime_data : 'a Core.t -> Core.qmimedata Core.t option = "caml_oqt6_qdrag_mime_data"
external qdrag_set_pixmap : 'a Core.t -> Pixmap.t -> unit = "caml_oqt6_qdrag_set_pixmap"
external qdrag_set_hot_spot : 'a Core.t -> int -> int -> unit = "caml_oqt6_qdrag_set_hot_spot"
external qdrag_exec_raw : 'a Core.t -> int -> int = "caml_oqt6_qdrag_exec"

module Drag = struct
  type qdrag = Core.qdrag
  type t = qdrag Core.t
  type drop_action = [ `Ignore | `Copy | `Move | `Link ]
  type actions_supported = [ `Copy | `Move | `Link | `Copy_or_move ]

  let int_of_actions = function
    | `Copy -> 0
    | `Move -> 1
    | `Link -> 2
    | `Copy_or_move -> 3

  let action_of_int = function
    | 1 -> `Copy
    | 2 -> `Move
    | 3 -> `Link
    | _ -> `Ignore

  let create parent = qdrag_create parent
  let set_mime_data = qdrag_set_mime_data
  let mime_data = qdrag_mime_data
  let set_pixmap = qdrag_set_pixmap
  let set_hot_spot drag ~x ~y = qdrag_set_hot_spot drag x y
  let exec ?(actions = `Copy_or_move) drag =
    action_of_int (qdrag_exec_raw drag (int_of_actions actions))
end

(* QClipboard *)
type clipboard_mode = [ `Clipboard | `Selection | `Find_buffer ]

let int_of_clipboard_mode = function
  | `Clipboard -> 0
  | `Selection -> 1
  | `Find_buffer -> 2

external clipboard_text_raw : int -> string option = "caml_oqt6_clipboard_text"
external clipboard_set_text_raw : string -> int -> unit = "caml_oqt6_clipboard_set_text"
external clipboard_pixmap_raw : int -> Pixmap.t option = "caml_oqt6_clipboard_pixmap"
external clipboard_set_pixmap_raw : Pixmap.t -> int -> unit = "caml_oqt6_clipboard_set_pixmap"
external clipboard_mime_data_raw : int -> Core.qmimedata Core.t option = "caml_oqt6_clipboard_mime_data"
external clipboard_set_mime_data_raw : 'a Core.t -> int -> unit = "caml_oqt6_clipboard_set_mime_data"
external clipboard_clear_raw : int -> unit = "caml_oqt6_clipboard_clear"
external clipboard_connect_changed : (unit -> unit) -> unit = "caml_oqt6_clipboard_connect_changed"

module Clipboard = struct
  type mode = clipboard_mode

  let text ?(mode = `Clipboard) () = clipboard_text_raw (int_of_clipboard_mode mode)
  let set_text ?(mode = `Clipboard) s = clipboard_set_text_raw s (int_of_clipboard_mode mode)
  let pixmap ?(mode = `Clipboard) () = clipboard_pixmap_raw (int_of_clipboard_mode mode)
  let set_pixmap ?(mode = `Clipboard) p = clipboard_set_pixmap_raw p (int_of_clipboard_mode mode)
  let mime_data ?(mode = `Clipboard) () = clipboard_mime_data_raw (int_of_clipboard_mode mode)
  let set_mime_data ?(mode = `Clipboard) m = clipboard_set_mime_data_raw m (int_of_clipboard_mode mode)
  let clear ?(mode = `Clipboard) () = clipboard_clear_raw (int_of_clipboard_mode mode)
  let on_changed = clipboard_connect_changed
end
