type orientation = [ `Horizontal | `Vertical ]

let int_of_orientation = function
  | `Horizontal -> 0
  | `Vertical -> 1

type selection_behavior = [ `Select_items | `Select_rows | `Select_columns ]
let int_of_selection_behavior = function
  | `Select_items -> 0
  | `Select_rows -> 1
  | `Select_columns -> 2

type selection_mode = [ `No_selection | `Single_selection | `Multi_selection | `Extended_selection | `Contiguous_selection ]
let int_of_selection_mode = function
  | `No_selection -> 0
  | `Single_selection -> 1
  | `Multi_selection -> 2
  | `Extended_selection -> 3
  | `Contiguous_selection -> 4

type header_resize_mode = [ `Interactive | `Stretch | `Fixed | `Resize_to_contents ]
let int_of_header_resize_mode = function
  | `Interactive -> 0
  | `Stretch -> 1
  | `Fixed -> 2
  | `Resize_to_contents -> 3

type mouse_button = [ `Left_button | `Right_button | `Middle_button | `No_button ]
type mouse_event = { x : int; y : int; button : mouse_button }
type key_event = { key : int; text : string }
type resize_event = { width : int; height : int; old_width : int; old_height : int }

type qwidget = [ Core.qobject | `QWidget ]
type qlayout = [ Core.qobject | `QLayout ]
type qbox_layout = [ qlayout | `QBoxLayout ]
type qvbox_layout = [ qbox_layout | `QVBoxLayout ]
type qhbox_layout = [ qbox_layout | `QHBoxLayout ]
type qgrid_layout = [ qlayout | `QGridLayout ]
type qpush_button = [ qwidget | `QPushButton ]
type qcheck_box = [ qwidget | `QCheckBox ]
type qradio_button = [ qwidget | `QRadioButton ]
type qcombo_box = [ qwidget | `QComboBox ]
type qspin_box = [ qwidget | `QSpinBox ]
type qslider = [ qwidget | `QSlider ]
type qprogress_bar = [ qwidget | `QProgressBar ]
type qtext_edit = [ qwidget | `QTextEdit ]
type qlabel = [ qwidget | `QLabel ]
type qline_edit = [ qwidget | `QLineEdit ]
type qcanvas = [ qwidget | `QCanvas ]
type qmain_window = [ qwidget | `QMainWindow ]
type qmenu_bar = [ qwidget | `QMenuBar ]
type qmenu = [ qwidget | `QMenu ]
type qaction = [ Core.qobject | `QAction ]
type qstatus_bar = [ qwidget | `QStatusBar ]
type qdialog = [ qwidget | `QDialog ]
type qapplication = [ Core.qobject | `QApplication ]

type qabstract_item_model = [ Core.qobject | `QAbstractItemModel ]
type qabstract_table_model = [ qabstract_item_model | `QAbstractTableModel ]
type qstandard_item_model = [ qabstract_item_model | `QStandardItemModel ]
type qocaml_table_model = [ qabstract_table_model | `QOCamlTableModel ]

type dock_area = [ `Left_dock | `Right_dock | `Top_dock | `Bottom_dock ]
let int_of_dock_area = function
  | `Left_dock -> 0
  | `Right_dock -> 1
  | `Top_dock -> 2
  | `Bottom_dock -> 3

type qabstract_item_view = [ qwidget | `QAbstractItemView ]
type qtable_view = [ qabstract_item_view | `QTableView ]
type qtree_view = [ qabstract_item_view | `QTreeView ]
type qlist_view = [ qabstract_item_view | `QListView ]
type qheader_view = [ qwidget | `QHeaderView ]
type qitem_selection_model = [ Core.qobject | `QItemSelectionModel ]

type qtab_widget = [ qwidget | `QTabWidget ]
type qstacked_widget = [ qwidget | `QStackedWidget ]
type qsplitter = [ qwidget | `QSplitter ]
type qscroll_area = [ qwidget | `QScrollArea ]
type qgroup_box = [ qwidget | `QGroupBox ]
type qtool_bar = [ qwidget | `QToolBar ]
type qdock_widget = [ qwidget | `QDockWidget ]
type qprogress_dialog = [ qdialog | `QProgressDialog ]

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
external qwidget_update : 'a Core.t -> unit = "caml_oqt6_qwidget_update"
external qwidget_set_mouse_tracking : 'a Core.t -> bool -> unit = "caml_oqt6_qwidget_set_mouse_tracking"

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
  let update = qwidget_update
  let set_mouse_tracking = qwidget_set_mouse_tracking
end

(* Button *)
external qpushbutton_create : string option -> 'a Core.t option -> qpush_button Core.t = "caml_oqt6_qpushbutton_create"
external qpushbutton_set_text : 'a Core.t -> string -> unit = "caml_oqt6_qpushbutton_set_text"
external qpushbutton_text : 'a Core.t -> string = "caml_oqt6_qpushbutton_text"
external qpushbutton_set_icon : 'a Core.t -> Gui.Icon.t -> unit = "caml_oqt6_qpushbutton_set_icon"
external qpushbutton_connect_clicked : 'a Core.t -> (unit -> unit) -> unit = "caml_oqt6_qpushbutton_connect_clicked"

module Button = struct
  let create ?text ?parent () = qpushbutton_create text parent
  let set_text = qpushbutton_set_text
  let text = qpushbutton_text
  let set_icon = qpushbutton_set_icon
  let on_clicked = qpushbutton_connect_clicked
end

(* CheckBox *)
external qcheckbox_create : string option -> 'a Core.t option -> qcheck_box Core.t = "caml_oqt6_qcheckbox_create"
external qcheckbox_set_checked : 'a Core.t -> bool -> unit = "caml_oqt6_qcheckbox_set_checked"
external qcheckbox_is_checked : 'a Core.t -> bool = "caml_oqt6_qcheckbox_is_checked"
external qcheckbox_set_text : 'a Core.t -> string -> unit = "caml_oqt6_qcheckbox_set_text"
external qcheckbox_text : 'a Core.t -> string = "caml_oqt6_qcheckbox_text"
external qcheckbox_connect_toggled : 'a Core.t -> (bool -> unit) -> unit = "caml_oqt6_qcheckbox_connect_toggled"

module CheckBox = struct
  let create ?text ?parent () = qcheckbox_create text parent
  let set_checked = qcheckbox_set_checked
  let is_checked = qcheckbox_is_checked
  let set_text = qcheckbox_set_text
  let text = qcheckbox_text
  let on_toggled = qcheckbox_connect_toggled
end

(* RadioButton *)
external qradiobutton_create : string option -> 'a Core.t option -> qradio_button Core.t = "caml_oqt6_qradiobutton_create"
external qradiobutton_set_checked : 'a Core.t -> bool -> unit = "caml_oqt6_qradiobutton_set_checked"
external qradiobutton_is_checked : 'a Core.t -> bool = "caml_oqt6_qradiobutton_is_checked"
external qradiobutton_set_text : 'a Core.t -> string -> unit = "caml_oqt6_qradiobutton_set_text"
external qradiobutton_text : 'a Core.t -> string = "caml_oqt6_qradiobutton_text"
external qradiobutton_connect_toggled : 'a Core.t -> (bool -> unit) -> unit = "caml_oqt6_qradiobutton_connect_toggled"

module RadioButton = struct
  let create ?text ?parent () = qradiobutton_create text parent
  let set_checked = qradiobutton_set_checked
  let is_checked = qradiobutton_is_checked
  let set_text = qradiobutton_set_text
  let text = qradiobutton_text
  let on_toggled = qradiobutton_connect_toggled
end

(* ComboBox *)
external qcombobox_create : 'a Core.t option -> qcombo_box Core.t = "caml_oqt6_qcombobox_create"
external qcombobox_add_item : 'a Core.t -> string -> unit = "caml_oqt6_qcombobox_add_item"
external qcombobox_count : 'a Core.t -> int = "caml_oqt6_qcombobox_count"
external qcombobox_current_index : 'a Core.t -> int = "caml_oqt6_qcombobox_current_index"
external qcombobox_set_current_index : 'a Core.t -> int -> unit = "caml_oqt6_qcombobox_set_current_index"
external qcombobox_current_text : 'a Core.t -> string = "caml_oqt6_qcombobox_current_text"
external qcombobox_item_text : 'a Core.t -> int -> string = "caml_oqt6_qcombobox_item_text"
external qcombobox_clear : 'a Core.t -> unit = "caml_oqt6_qcombobox_clear"
external qcombobox_connect_current_index_changed : 'a Core.t -> (int -> unit) -> unit = "caml_oqt6_qcombobox_connect_current_index_changed"
external qcombobox_connect_current_text_changed : 'a Core.t -> (string -> unit) -> unit = "caml_oqt6_qcombobox_connect_current_text_changed"

module ComboBox = struct
  let create ?parent () = qcombobox_create parent
  let add_item = qcombobox_add_item
  let add_items cb items = List.iter (qcombobox_add_item cb) items
  let count = qcombobox_count
  let current_index = qcombobox_current_index
  let set_current_index = qcombobox_set_current_index
  let current_text = qcombobox_current_text
  let item_text = qcombobox_item_text
  let clear = qcombobox_clear
  let on_current_index_changed = qcombobox_connect_current_index_changed
  let on_current_text_changed = qcombobox_connect_current_text_changed
end

(* SpinBox *)
external qspinbox_create : 'a Core.t option -> qspin_box Core.t = "caml_oqt6_qspinbox_create"
external qspinbox_value : 'a Core.t -> int = "caml_oqt6_qspinbox_value"
external qspinbox_set_value : 'a Core.t -> int -> unit = "caml_oqt6_qspinbox_set_value"
external qspinbox_set_minimum : 'a Core.t -> int -> unit = "caml_oqt6_qspinbox_set_minimum"
external qspinbox_set_maximum : 'a Core.t -> int -> unit = "caml_oqt6_qspinbox_set_maximum"
external qspinbox_set_range : 'a Core.t -> int -> int -> unit = "caml_oqt6_qspinbox_set_range"
external qspinbox_set_single_step : 'a Core.t -> int -> unit = "caml_oqt6_qspinbox_set_single_step"
external qspinbox_set_prefix : 'a Core.t -> string -> unit = "caml_oqt6_qspinbox_set_prefix"
external qspinbox_set_suffix : 'a Core.t -> string -> unit = "caml_oqt6_qspinbox_set_suffix"
external qspinbox_connect_value_changed : 'a Core.t -> (int -> unit) -> unit = "caml_oqt6_qspinbox_connect_value_changed"

module SpinBox = struct
  let create ?parent () = qspinbox_create parent
  let value = qspinbox_value
  let set_value = qspinbox_set_value
  let set_minimum = qspinbox_set_minimum
  let set_maximum = qspinbox_set_maximum
  let set_range sb ~min ~max = qspinbox_set_range sb min max
  let set_single_step = qspinbox_set_single_step
  let set_prefix = qspinbox_set_prefix
  let set_suffix = qspinbox_set_suffix
  let on_value_changed = qspinbox_connect_value_changed
end

(* Slider *)
external qslider_create : int option -> 'a Core.t option -> qslider Core.t = "caml_oqt6_qslider_create"
external qslider_value : 'a Core.t -> int = "caml_oqt6_qslider_value"
external qslider_set_value : 'a Core.t -> int -> unit = "caml_oqt6_qslider_set_value"
external qslider_set_minimum : 'a Core.t -> int -> unit = "caml_oqt6_qslider_set_minimum"
external qslider_set_maximum : 'a Core.t -> int -> unit = "caml_oqt6_qslider_set_maximum"
external qslider_set_range : 'a Core.t -> int -> int -> unit = "caml_oqt6_qslider_set_range"
external qslider_set_single_step : 'a Core.t -> int -> unit = "caml_oqt6_qslider_set_single_step"
external qslider_set_orientation : 'a Core.t -> int -> unit = "caml_oqt6_qslider_set_orientation"
external qslider_connect_value_changed : 'a Core.t -> (int -> unit) -> unit = "caml_oqt6_qslider_connect_value_changed"

module Slider = struct
  let create ?orientation ?parent () =
    let orient = Option.map int_of_orientation orientation in
    qslider_create orient parent
  let value = qslider_value
  let set_value = qslider_set_value
  let set_minimum = qslider_set_minimum
  let set_maximum = qslider_set_maximum
  let set_range s ~min ~max = qslider_set_range s min max
  let set_single_step = qslider_set_single_step
  let set_orientation s orient = qslider_set_orientation s (int_of_orientation orient)
  let on_value_changed = qslider_connect_value_changed
end

(* ProgressBar *)
external qprogressbar_create : 'a Core.t option -> qprogress_bar Core.t = "caml_oqt6_qprogressbar_create"
external qprogressbar_value : 'a Core.t -> int = "caml_oqt6_qprogressbar_value"
external qprogressbar_set_value : 'a Core.t -> int -> unit = "caml_oqt6_qprogressbar_set_value"
external qprogressbar_set_minimum : 'a Core.t -> int -> unit = "caml_oqt6_qprogressbar_set_minimum"
external qprogressbar_set_maximum : 'a Core.t -> int -> unit = "caml_oqt6_qprogressbar_set_maximum"
external qprogressbar_set_range : 'a Core.t -> int -> int -> unit = "caml_oqt6_qprogressbar_set_range"
external qprogressbar_set_format : 'a Core.t -> string -> unit = "caml_oqt6_qprogressbar_set_format"
external qprogressbar_reset : 'a Core.t -> unit = "caml_oqt6_qprogressbar_reset"

module ProgressBar = struct
  let create ?parent () = qprogressbar_create parent
  let value = qprogressbar_value
  let set_value = qprogressbar_set_value
  let set_minimum = qprogressbar_set_minimum
  let set_maximum = qprogressbar_set_maximum
  let set_range pb ~min ~max = qprogressbar_set_range pb min max
  let set_format = qprogressbar_set_format
  let reset = qprogressbar_reset
end

(* TextEdit *)
external qtextedit_create : string option -> 'a Core.t option -> qtext_edit Core.t = "caml_oqt6_qtextedit_create"
external qtextedit_to_plain_text : 'a Core.t -> string = "caml_oqt6_qtextedit_to_plain_text"
external qtextedit_set_plain_text : 'a Core.t -> string -> unit = "caml_oqt6_qtextedit_set_plain_text"
external qtextedit_to_html : 'a Core.t -> string = "caml_oqt6_qtextedit_to_html"
external qtextedit_set_html : 'a Core.t -> string -> unit = "caml_oqt6_qtextedit_set_html"
external qtextedit_append : 'a Core.t -> string -> unit = "caml_oqt6_qtextedit_append"
external qtextedit_clear : 'a Core.t -> unit = "caml_oqt6_qtextedit_clear"
external qtextedit_set_read_only : 'a Core.t -> bool -> unit = "caml_oqt6_qtextedit_set_read_only"
external qtextedit_is_read_only : 'a Core.t -> bool = "caml_oqt6_qtextedit_is_read_only"
external qtextedit_connect_text_changed : 'a Core.t -> (unit -> unit) -> unit = "caml_oqt6_qtextedit_connect_text_changed"

module TextEdit = struct
  let create ?text ?parent () = qtextedit_create text parent
  let to_plain_text = qtextedit_to_plain_text
  let set_plain_text = qtextedit_set_plain_text
  let to_html = qtextedit_to_html
  let set_html = qtextedit_set_html
  let append = qtextedit_append
  let clear = qtextedit_clear
  let set_read_only = qtextedit_set_read_only
  let is_read_only = qtextedit_is_read_only
  let on_text_changed = qtextedit_connect_text_changed
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

(* Canvas *)
external qcanvas_create : 'a Core.t option -> qcanvas Core.t = "caml_oqt6_qcanvas_create"
external qcanvas_on_paint : 'a Core.t -> (Gui.Painter.t -> unit) -> unit = "caml_oqt6_qcanvas_on_paint"
external qcanvas_on_mouse_press : 'a Core.t -> (int -> int -> int -> unit) -> unit = "caml_oqt6_qcanvas_on_mouse_press"
external qcanvas_on_mouse_release : 'a Core.t -> (int -> int -> int -> unit) -> unit = "caml_oqt6_qcanvas_on_mouse_release"
external qcanvas_on_mouse_move : 'a Core.t -> (int -> int -> int -> unit) -> unit = "caml_oqt6_qcanvas_on_mouse_move"
external qcanvas_on_key_press : 'a Core.t -> (int -> string -> unit) -> unit = "caml_oqt6_qcanvas_on_key_press"
external qcanvas_on_resize : 'a Core.t -> (int -> int -> int -> int -> unit) -> unit = "caml_oqt6_qcanvas_on_resize"

module Canvas = struct
  let create ?parent () = qcanvas_create parent
  let on_paint = qcanvas_on_paint

  let wrap_mouse_cb cb x y btn_int =
    let button = match btn_int with
      | 0 -> `Left_button
      | 1 -> `Right_button
      | 2 -> `Middle_button
      | _ -> `No_button
    in
    cb { x; y; button }

  let on_mouse_press c cb = qcanvas_on_mouse_press c (wrap_mouse_cb cb)
  let on_mouse_release c cb = qcanvas_on_mouse_release c (wrap_mouse_cb cb)
  let on_mouse_move c cb = qcanvas_on_mouse_move c (wrap_mouse_cb cb)

  let on_key_press c cb =
    qcanvas_on_key_press c (fun key text -> cb { key; text })

  let on_resize c cb =
    qcanvas_on_resize c (fun width height old_width old_height -> cb { width; height; old_width; old_height })

  let update = qwidget_update
  let set_mouse_tracking = qwidget_set_mouse_tracking
end

(* MainWindow *)
external qmainwindow_create : 'a Core.t option -> qmain_window Core.t = "caml_oqt6_qmainwindow_create"
external qmainwindow_set_central_widget : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qmainwindow_set_central_widget"
external qmainwindow_central_widget : 'a Core.t -> qwidget Core.t option = "caml_oqt6_qmainwindow_central_widget"
external qmainwindow_menu_bar : 'a Core.t -> qmenu_bar Core.t = "caml_oqt6_qmainwindow_menu_bar"
external qmainwindow_status_bar : 'a Core.t -> qstatus_bar Core.t = "caml_oqt6_qmainwindow_status_bar"
external qmainwindow_set_status_bar : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qmainwindow_set_status_bar"
external qmainwindow_set_window_icon : 'a Core.t -> Gui.Icon.t -> unit = "caml_oqt6_qmainwindow_set_window_icon"
external qmainwindow_add_toolbar : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qmainwindow_add_toolbar"
external qmainwindow_add_toolbar_title : 'a Core.t -> string -> qtool_bar Core.t = "caml_oqt6_qmainwindow_add_toolbar_title"
external qmainwindow_add_dockwidget : 'a Core.t -> int -> 'b Core.t -> unit = "caml_oqt6_qmainwindow_add_dockwidget"

module MainWindow = struct
  let create ?parent () = qmainwindow_create parent
  let set_central_widget = qmainwindow_set_central_widget
  let central_widget = qmainwindow_central_widget
  let menu_bar = qmainwindow_menu_bar
  let status_bar = qmainwindow_status_bar
  let set_status_bar = qmainwindow_set_status_bar
  let set_window_icon = qmainwindow_set_window_icon
  let add_tool_bar = qmainwindow_add_toolbar
  let add_tool_bar_title = qmainwindow_add_toolbar_title
  let add_dock_widget win area dw = qmainwindow_add_dockwidget win (int_of_dock_area area) dw
end

(* MenuBar *)
external qmenubar_add_menu : 'a Core.t -> string -> qmenu Core.t = "caml_oqt6_qmenubar_add_menu"
external qmenubar_add_action : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qmenubar_add_action"
external qmenubar_clear : 'a Core.t -> unit = "caml_oqt6_qmenubar_clear"

module MenuBar = struct
  let add_menu = qmenubar_add_menu
  let add_action = qmenubar_add_action
  let clear = qmenubar_clear
end

(* Menu *)
external qmenu_add_action : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qmenu_add_action"
external qmenu_add_menu : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qmenu_add_menu"
external qmenu_add_action_text : 'a Core.t -> string -> qaction Core.t = "caml_oqt6_qmenu_add_action_text"
external qmenu_add_separator : 'a Core.t -> unit = "caml_oqt6_qmenu_add_separator"
external qmenu_clear : 'a Core.t -> unit = "caml_oqt6_qmenu_clear"

module Menu = struct
  let add_action = qmenu_add_action
  let add_menu = qmenu_add_menu
  let add_action_text = qmenu_add_action_text
  let add_separator = qmenu_add_separator
  let clear = qmenu_clear
end

(* Action *)
external qaction_create : string option -> 'a Core.t option -> qaction Core.t = "caml_oqt6_qaction_create"
external qaction_set_text : 'a Core.t -> string -> unit = "caml_oqt6_qaction_set_text"
external qaction_text : 'a Core.t -> string = "caml_oqt6_qaction_text"
external qaction_set_icon : 'a Core.t -> Gui.Icon.t -> unit = "caml_oqt6_qaction_set_icon"
external qaction_set_checkable : 'a Core.t -> bool -> unit = "caml_oqt6_qaction_set_checkable"
external qaction_is_checkable : 'a Core.t -> bool = "caml_oqt6_qaction_is_checkable"
external qaction_set_checked : 'a Core.t -> bool -> unit = "caml_oqt6_qaction_set_checked"
external qaction_is_checked : 'a Core.t -> bool = "caml_oqt6_qaction_is_checked"
external qaction_set_enabled : 'a Core.t -> bool -> unit = "caml_oqt6_qaction_set_enabled"
external qaction_is_enabled : 'a Core.t -> bool = "caml_oqt6_qaction_is_enabled"
external qaction_set_shortcut : 'a Core.t -> string -> unit = "caml_oqt6_qaction_set_shortcut"
external qaction_connect_triggered : 'a Core.t -> (bool -> unit) -> unit = "caml_oqt6_qaction_connect_triggered"

module Action = struct
  let create ?text ?parent () = qaction_create text parent
  let set_text = qaction_set_text
  let text = qaction_text
  let set_icon = qaction_set_icon
  let set_checkable = qaction_set_checkable
  let is_checkable = qaction_is_checkable
  let set_checked = qaction_set_checked
  let is_checked = qaction_is_checked
  let set_enabled = qaction_set_enabled
  let is_enabled = qaction_is_enabled
  let set_shortcut = qaction_set_shortcut
  let on_triggered = qaction_connect_triggered
end

(* StatusBar *)
external qstatusbar_show_message : 'a Core.t -> int option -> string -> unit = "caml_oqt6_qstatusbar_show_message"
external qstatusbar_clear_message : 'a Core.t -> unit = "caml_oqt6_qstatusbar_clear_message"
external qstatusbar_current_message : 'a Core.t -> string = "caml_oqt6_qstatusbar_current_message"

module StatusBar = struct
  let show_message sb ?timeout msg = qstatusbar_show_message sb timeout msg
  let clear_message = qstatusbar_clear_message
  let current_message = qstatusbar_current_message
end

(* Dialog *)
external qdialog_create : 'a Core.t option -> qdialog Core.t = "caml_oqt6_qdialog_create"
external qdialog_exec : 'a Core.t -> int = "caml_oqt6_qdialog_exec"
external qdialog_accept : 'a Core.t -> unit = "caml_oqt6_qdialog_accept"
external qdialog_reject : 'a Core.t -> unit = "caml_oqt6_qdialog_reject"
external qdialog_set_modal : 'a Core.t -> bool -> unit = "caml_oqt6_qdialog_set_modal"
external qdialog_is_modal : 'a Core.t -> bool = "caml_oqt6_qdialog_is_modal"

module Dialog = struct
  let create ?parent () = qdialog_create parent
  let exec = qdialog_exec
  let accept = qdialog_accept
  let reject = qdialog_reject
  let set_modal = qdialog_set_modal
  let is_modal = qdialog_is_modal
end

(* MessageBox *)
external qmessagebox_information : 'a Core.t option -> string -> string -> unit = "caml_oqt6_qmessagebox_information"
external qmessagebox_warning : 'a Core.t option -> string -> string -> unit = "caml_oqt6_qmessagebox_warning"
external qmessagebox_critical : 'a Core.t option -> string -> string -> unit = "caml_oqt6_qmessagebox_critical"
external qmessagebox_question : 'a Core.t option -> string -> string -> bool = "caml_oqt6_qmessagebox_question"

module MessageBox = struct
  let information ?parent ~title ~text () = qmessagebox_information parent title text
  let warning ?parent ~title ~text () = qmessagebox_warning parent title text
  let critical ?parent ~title ~text () = qmessagebox_critical parent title text
  let question ?parent ~title ~text () = qmessagebox_question parent title text
end

(* FileDialog *)
external qfiledialog_get_open_file_name : 'a Core.t option -> string option -> string option -> string option -> string option = "caml_oqt6_qfiledialog_get_open_file_name"
external qfiledialog_get_save_file_name : 'a Core.t option -> string option -> string option -> string option -> string option = "caml_oqt6_qfiledialog_get_save_file_name"
external qfiledialog_get_existing_directory : 'a Core.t option -> string option -> string option -> string option = "caml_oqt6_qfiledialog_get_existing_directory"

module FileDialog = struct
  let get_open_file_name ?parent ?caption ?dir ?filter () =
    qfiledialog_get_open_file_name parent caption dir filter
  let get_save_file_name ?parent ?caption ?dir ?filter () =
    qfiledialog_get_save_file_name parent caption dir filter
  let get_existing_directory ?parent ?caption ?dir () =
    qfiledialog_get_existing_directory parent caption dir
end

(* Layout *)
external qvboxlayout_create : 'a Core.t option -> qvbox_layout Core.t = "caml_oqt6_qvboxlayout_create"
external qhboxlayout_create : 'a Core.t option -> qhbox_layout Core.t = "caml_oqt6_qhboxlayout_create"
external qboxlayout_add_widget : 'a Core.t -> int option -> 'b Core.t -> unit = "caml_oqt6_qboxlayout_add_widget"
external qboxlayout_add_layout : 'a Core.t -> int option -> 'b Core.t -> unit = "caml_oqt6_qboxlayout_add_layout"
external qboxlayout_add_stretch : 'a Core.t -> int option -> unit = "caml_oqt6_qboxlayout_add_stretch"
external qboxlayout_add_spacing : 'a Core.t -> int -> unit = "caml_oqt6_qboxlayout_add_spacing"

external qgridlayout_create : 'a Core.t option -> qgrid_layout Core.t = "caml_oqt6_qgridlayout_create"
external qgridlayout_add_widget : 'a Core.t -> int -> int -> int option -> int option -> 'b Core.t -> unit = "caml_oqt6_qgridlayout_add_widget_byte" "caml_oqt6_qgridlayout_add_widget"
external qgridlayout_add_layout : 'a Core.t -> int -> int -> int option -> int option -> 'b Core.t -> unit = "caml_oqt6_qgridlayout_add_layout_byte" "caml_oqt6_qgridlayout_add_layout"
external qgridlayout_set_row_stretch : 'a Core.t -> int -> int -> unit = "caml_oqt6_qgridlayout_set_row_stretch"
external qgridlayout_set_column_stretch : 'a Core.t -> int -> int -> unit = "caml_oqt6_qgridlayout_set_column_stretch"
external qgridlayout_set_spacing : 'a Core.t -> int -> unit = "caml_oqt6_qgridlayout_set_spacing"

module Layout = struct
  module VBox = struct
    let create ?parent () = qvboxlayout_create parent
  end

  module HBox = struct
    let create ?parent () = qhboxlayout_create parent
  end

  module Grid = struct
    let create ?parent () = qgridlayout_create parent
    let add_widget gl ~row ~col ?row_span ?col_span w =
      qgridlayout_add_widget gl row col row_span col_span w
    let add_layout gl ~row ~col ?row_span ?col_span sub =
      qgridlayout_add_layout gl row col row_span col_span sub
    let set_row_stretch gl ~row ~stretch = qgridlayout_set_row_stretch gl row stretch
    let set_column_stretch gl ~col ~stretch = qgridlayout_set_column_stretch gl col stretch
    let set_spacing = qgridlayout_set_spacing
  end

  let add_widget l ?stretch w = qboxlayout_add_widget l stretch w
  let add_layout l ?stretch sub = qboxlayout_add_layout l stretch sub
  let add_stretch l ?stretch () = qboxlayout_add_stretch l stretch
  let add_spacing = qboxlayout_add_spacing
end

(* ItemSelectionModel *)
external qitemselectionmodel_clear_selection : 'a Core.t -> unit = "caml_oqt6_qitemselectionmodel_clear_selection"
external qitemselectionmodel_has_selection : 'a Core.t -> bool = "caml_oqt6_qitemselectionmodel_has_selection"
external qitemselectionmodel_selected_rows : 'a Core.t -> int list = "caml_oqt6_qitemselectionmodel_selected_rows"
external qitemselectionmodel_current_row : 'a Core.t -> int = "caml_oqt6_qitemselectionmodel_current_row"
external qitemselectionmodel_current_column : 'a Core.t -> int = "caml_oqt6_qitemselectionmodel_current_column"
external qitemselectionmodel_connect_selection_changed : 'a Core.t -> (unit -> unit) -> unit = "caml_oqt6_qitemselectionmodel_connect_selection_changed"
external qitemselectionmodel_connect_current_changed : 'a Core.t -> (int -> int -> unit) -> unit = "caml_oqt6_qitemselectionmodel_connect_current_changed"

module ItemSelectionModel = struct
  let clear_selection = qitemselectionmodel_clear_selection
  let has_selection = qitemselectionmodel_has_selection
  let selected_rows = qitemselectionmodel_selected_rows
  let current_row = qitemselectionmodel_current_row
  let current_column = qitemselectionmodel_current_column
  let on_selection_changed = qitemselectionmodel_connect_selection_changed
  let on_current_changed = qitemselectionmodel_connect_current_changed
end

(* HeaderView *)
external qheaderview_set_stretch_last_section : 'a Core.t -> bool -> unit = "caml_oqt6_qheaderview_set_stretch_last_section"
external qheaderview_is_stretch_last_section : 'a Core.t -> bool = "caml_oqt6_qheaderview_is_stretch_last_section"
external qheaderview_set_section_resize_mode : 'a Core.t -> int -> unit = "caml_oqt6_qheaderview_set_section_resize_mode"
external qheaderview_set_section_resize_mode_section : 'a Core.t -> int -> int -> unit = "caml_oqt6_qheaderview_set_section_resize_mode_section"

module HeaderView = struct
  let set_stretch_last_section = qheaderview_set_stretch_last_section
  let is_stretch_last_section = qheaderview_is_stretch_last_section
  let set_section_resize_mode h ?section mode =
    let m = int_of_header_resize_mode mode in
    match section with
    | None -> qheaderview_set_section_resize_mode h m
    | Some s -> qheaderview_set_section_resize_mode_section h s m
end

(* StandardItemModel *)
external qstandarditemmodel_create : int option -> int option -> 'a Core.t option -> qstandard_item_model Core.t = "caml_oqt6_qstandarditemmodel_create"
external qstandarditemmodel_set_item : 'a Core.t -> int -> int -> string -> unit = "caml_oqt6_qstandarditemmodel_set_item"
external qstandarditemmodel_item_text : 'a Core.t -> int -> int -> string = "caml_oqt6_qstandarditemmodel_item_text"
external qstandarditemmodel_set_horizontal_header_labels : 'a Core.t -> string list -> unit = "caml_oqt6_qstandarditemmodel_set_horizontal_header_labels"
external qstandarditemmodel_set_vertical_header_labels : 'a Core.t -> string list -> unit = "caml_oqt6_qstandarditemmodel_set_vertical_header_labels"
external qstandarditemmodel_row_count : 'a Core.t -> int = "caml_oqt6_qstandarditemmodel_row_count"
external qstandarditemmodel_column_count : 'a Core.t -> int = "caml_oqt6_qstandarditemmodel_column_count"
external qstandarditemmodel_clear : 'a Core.t -> unit = "caml_oqt6_qstandarditemmodel_clear"
external qstandarditemmodel_append_row : 'a Core.t -> string list -> unit = "caml_oqt6_qstandarditemmodel_append_row"
external qstandarditemmodel_remove_row : 'a Core.t -> int -> unit = "caml_oqt6_qstandarditemmodel_remove_row"
external qstandarditemmodel_remove_column : 'a Core.t -> int -> unit = "caml_oqt6_qstandarditemmodel_remove_column"

module StandardItemModel = struct
  let create ?rows ?cols ?parent () = qstandarditemmodel_create rows cols parent
  let set_item m ~row ~col ~text = qstandarditemmodel_set_item m row col text
  let item_text m ~row ~col = qstandarditemmodel_item_text m row col
  let set_horizontal_header_labels = qstandarditemmodel_set_horizontal_header_labels
  let set_vertical_header_labels = qstandarditemmodel_set_vertical_header_labels
  let row_count = qstandarditemmodel_row_count
  let column_count = qstandarditemmodel_column_count
  let clear = qstandarditemmodel_clear
  let append_row = qstandarditemmodel_append_row
  let remove_row = qstandarditemmodel_remove_row
  let remove_column = qstandarditemmodel_remove_column
end

(* TableModel *)
external qtablemodel_create : 'a Core.t option -> qocaml_table_model Core.t = "caml_oqt6_tablemodel_create"
external qtablemodel_set_callbacks : 'a Core.t -> (unit -> int) -> (unit -> int) -> (int -> int -> string) -> (int -> int -> string) option -> unit = "caml_oqt6_tablemodel_set_callbacks"
external qtablemodel_notify_reset : 'a Core.t -> unit = "caml_oqt6_tablemodel_notify_reset"
external qtablemodel_notify_data_changed : 'a Core.t -> int -> int -> int -> int -> unit = "caml_oqt6_tablemodel_notify_data_changed"

module TableModel = struct
  let create ?parent ~row_count ~col_count ~data ?header_data () =
    let m = qtablemodel_create parent in
    let header_cb = Option.map (fun cb sec orient_int ->
      let orient = if orient_int = 0 then `Horizontal else `Vertical in
      cb sec orient
    ) header_data in
    qtablemodel_set_callbacks m row_count col_count data header_cb;
    m

  let notify_reset = qtablemodel_notify_reset
  let notify_data_changed m ~top_row ~left_col ~bottom_row ~right_col =
    qtablemodel_notify_data_changed m top_row left_col bottom_row right_col
end

(* TableView *)
external qtableview_create : 'a Core.t option -> qtable_view Core.t = "caml_oqt6_qtableview_create"
external qtableview_set_model : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qtableview_set_model"
external qtableview_set_selection_behavior : 'a Core.t -> int -> unit = "caml_oqt6_qtableview_set_selection_behavior"
external qtableview_set_selection_mode : 'a Core.t -> int -> unit = "caml_oqt6_qtableview_set_selection_mode"
external qtableview_set_sorting_enabled : 'a Core.t -> bool -> unit = "caml_oqt6_qtableview_set_sorting_enabled"
external qtableview_set_show_grid : 'a Core.t -> bool -> unit = "caml_oqt6_qtableview_set_show_grid"
external qtableview_set_alternating_row_colors : 'a Core.t -> bool -> unit = "caml_oqt6_qtableview_set_alternating_row_colors"
external qtableview_resize_columns_to_contents : 'a Core.t -> unit = "caml_oqt6_qtableview_resize_columns_to_contents"
external qtableview_resize_rows_to_contents : 'a Core.t -> unit = "caml_oqt6_qtableview_resize_rows_to_contents"
external qtableview_horizontal_header : 'a Core.t -> qheader_view Core.t = "caml_oqt6_qtableview_horizontal_header"
external qtableview_vertical_header : 'a Core.t -> qheader_view Core.t = "caml_oqt6_qtableview_vertical_header"
external qtableview_selection_model : 'a Core.t -> qitem_selection_model Core.t = "caml_oqt6_qtableview_selection_model"
external qtableview_connect_clicked : 'a Core.t -> (int -> int -> unit) -> unit = "caml_oqt6_qtableview_connect_clicked"
external qtableview_connect_double_clicked : 'a Core.t -> (int -> int -> unit) -> unit = "caml_oqt6_qtableview_connect_double_clicked"

module TableView = struct
  let create ?parent () = qtableview_create parent
  let set_model = qtableview_set_model
  let set_selection_behavior tv beh = qtableview_set_selection_behavior tv (int_of_selection_behavior beh)
  let set_selection_mode tv mode = qtableview_set_selection_mode tv (int_of_selection_mode mode)
  let set_sorting_enabled = qtableview_set_sorting_enabled
  let set_show_grid = qtableview_set_show_grid
  let set_alternating_row_colors = qtableview_set_alternating_row_colors
  let resize_columns_to_contents = qtableview_resize_columns_to_contents
  let resize_rows_to_contents = qtableview_resize_rows_to_contents
  let horizontal_header = qtableview_horizontal_header
  let vertical_header = qtableview_vertical_header
  let selection_model = qtableview_selection_model
  let on_clicked = qtableview_connect_clicked
  let on_double_clicked = qtableview_connect_double_clicked
end

(* TreeView *)
external qtreeview_create : 'a Core.t option -> qtree_view Core.t = "caml_oqt6_qtreeview_create"
external qtreeview_set_model : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qtreeview_set_model"
external qtreeview_set_selection_behavior : 'a Core.t -> int -> unit = "caml_oqt6_qtreeview_set_selection_behavior"
external qtreeview_set_selection_mode : 'a Core.t -> int -> unit = "caml_oqt6_qtreeview_set_selection_mode"
external qtreeview_set_sorting_enabled : 'a Core.t -> bool -> unit = "caml_oqt6_qtreeview_set_sorting_enabled"
external qtreeview_set_alternating_row_colors : 'a Core.t -> bool -> unit = "caml_oqt6_qtreeview_set_alternating_row_colors"
external qtreeview_expand_all : 'a Core.t -> unit = "caml_oqt6_qtreeview_expand_all"
external qtreeview_collapse_all : 'a Core.t -> unit = "caml_oqt6_qtreeview_collapse_all"
external qtreeview_header : 'a Core.t -> qheader_view Core.t = "caml_oqt6_qtreeview_header"
external qtreeview_selection_model : 'a Core.t -> qitem_selection_model Core.t = "caml_oqt6_qtreeview_selection_model"
external qtreeview_connect_clicked : 'a Core.t -> (int -> int -> unit) -> unit = "caml_oqt6_qtreeview_connect_clicked"

module TreeView = struct
  let create ?parent () = qtreeview_create parent
  let set_model = qtreeview_set_model
  let set_selection_behavior tv beh = qtreeview_set_selection_behavior tv (int_of_selection_behavior beh)
  let set_selection_mode tv mode = qtreeview_set_selection_mode tv (int_of_selection_mode mode)
  let set_sorting_enabled = qtreeview_set_sorting_enabled
  let set_alternating_row_colors = qtreeview_set_alternating_row_colors
  let expand_all = qtreeview_expand_all
  let collapse_all = qtreeview_collapse_all
  let header = qtreeview_header
  let selection_model = qtreeview_selection_model
  let on_clicked = qtreeview_connect_clicked
end

(* ListView *)
external qlistview_create : 'a Core.t option -> qlist_view Core.t = "caml_oqt6_qlistview_create"
external qlistview_set_model : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qlistview_set_model"
external qlistview_set_selection_behavior : 'a Core.t -> int -> unit = "caml_oqt6_qlistview_set_selection_behavior"
external qlistview_set_selection_mode : 'a Core.t -> int -> unit = "caml_oqt6_qlistview_set_selection_mode"
external qlistview_selection_model : 'a Core.t -> qitem_selection_model Core.t = "caml_oqt6_qlistview_selection_model"
external qlistview_connect_clicked : 'a Core.t -> (int -> unit) -> unit = "caml_oqt6_qlistview_connect_clicked"

module ListView = struct
  let create ?parent () = qlistview_create parent
  let set_model = qlistview_set_model
  let set_selection_behavior lv beh = qlistview_set_selection_behavior lv (int_of_selection_behavior beh)
  let set_selection_mode lv mode = qlistview_set_selection_mode lv (int_of_selection_mode mode)
  let selection_model = qlistview_selection_model
  let on_clicked = qlistview_connect_clicked
end

(* TabWidget *)
external qtabwidget_create : 'a Core.t option -> qtab_widget Core.t = "caml_oqt6_qtabwidget_create"
external qtabwidget_add_tab : 'a Core.t -> 'b Core.t -> string -> int = "caml_oqt6_qtabwidget_add_tab"
external qtabwidget_insert_tab : 'a Core.t -> int -> 'b Core.t -> string -> int = "caml_oqt6_qtabwidget_insert_tab"
external qtabwidget_remove_tab : 'a Core.t -> int -> unit = "caml_oqt6_qtabwidget_remove_tab"
external qtabwidget_current_index : 'a Core.t -> int = "caml_oqt6_qtabwidget_current_index"
external qtabwidget_set_current_index : 'a Core.t -> int -> unit = "caml_oqt6_qtabwidget_set_current_index"
external qtabwidget_count : 'a Core.t -> int = "caml_oqt6_qtabwidget_count"
external qtabwidget_tab_text : 'a Core.t -> int -> string = "caml_oqt6_qtabwidget_tab_text"
external qtabwidget_set_tab_text : 'a Core.t -> int -> string -> unit = "caml_oqt6_qtabwidget_set_tab_text"
external qtabwidget_set_tabs_closable : 'a Core.t -> bool -> unit = "caml_oqt6_qtabwidget_set_tabs_closable"
external qtabwidget_set_movable : 'a Core.t -> bool -> unit = "caml_oqt6_qtabwidget_set_movable"
external qtabwidget_set_tab_icon : 'a Core.t -> int -> Gui.Icon.t -> unit = "caml_oqt6_qtabwidget_set_tab_icon"
external qtabwidget_connect_current_changed : 'a Core.t -> (int -> unit) -> unit = "caml_oqt6_qtabwidget_connect_current_changed"
external qtabwidget_connect_tab_close_requested : 'a Core.t -> (int -> unit) -> unit = "caml_oqt6_qtabwidget_connect_tab_close_requested"

module TabWidget = struct
  let create ?parent () = qtabwidget_create parent
  let add_tab tw ~label w = qtabwidget_add_tab tw w label
  let insert_tab tw ~index ~label w = qtabwidget_insert_tab tw index w label
  let remove_tab = qtabwidget_remove_tab
  let current_index = qtabwidget_current_index
  let set_current_index = qtabwidget_set_current_index
  let count = qtabwidget_count
  let tab_text = qtabwidget_tab_text
  let set_tab_text = qtabwidget_set_tab_text
  let set_tabs_closable = qtabwidget_set_tabs_closable
  let set_movable = qtabwidget_set_movable
  let set_tab_icon = qtabwidget_set_tab_icon
  let on_current_changed = qtabwidget_connect_current_changed
  let on_tab_close_requested = qtabwidget_connect_tab_close_requested
end

(* StackedWidget *)
external qstackedwidget_create : 'a Core.t option -> qstacked_widget Core.t = "caml_oqt6_qstackedwidget_create"
external qstackedwidget_add_widget : 'a Core.t -> 'b Core.t -> int = "caml_oqt6_qstackedwidget_add_widget"
external qstackedwidget_remove_widget : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qstackedwidget_remove_widget"
external qstackedwidget_current_index : 'a Core.t -> int = "caml_oqt6_qstackedwidget_current_index"
external qstackedwidget_set_current_index : 'a Core.t -> int -> unit = "caml_oqt6_qstackedwidget_set_current_index"
external qstackedwidget_count : 'a Core.t -> int = "caml_oqt6_qstackedwidget_count"
external qstackedwidget_connect_current_changed : 'a Core.t -> (int -> unit) -> unit = "caml_oqt6_qstackedwidget_connect_current_changed"

module StackedWidget = struct
  let create ?parent () = qstackedwidget_create parent
  let add_widget = qstackedwidget_add_widget
  let remove_widget = qstackedwidget_remove_widget
  let current_index = qstackedwidget_current_index
  let set_current_index = qstackedwidget_set_current_index
  let count = qstackedwidget_count
  let on_current_changed = qstackedwidget_connect_current_changed
end

(* Splitter *)
external qsplitter_create : int option -> 'a Core.t option -> qsplitter Core.t = "caml_oqt6_qsplitter_create"
external qsplitter_add_widget : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qsplitter_add_widget"
external qsplitter_set_orientation : 'a Core.t -> int -> unit = "caml_oqt6_qsplitter_set_orientation"
external qsplitter_orientation : 'a Core.t -> int = "caml_oqt6_qsplitter_orientation"
external qsplitter_set_sizes : 'a Core.t -> int list -> unit = "caml_oqt6_qsplitter_set_sizes"
external qsplitter_sizes : 'a Core.t -> int list = "caml_oqt6_qsplitter_sizes"
external qsplitter_set_stretch_factor : 'a Core.t -> int -> int -> unit = "caml_oqt6_qsplitter_set_stretch_factor"

module Splitter = struct
  let create ?orientation ?parent () =
    let o = Option.map int_of_orientation orientation in
    qsplitter_create o parent
  let add_widget = qsplitter_add_widget
  let set_orientation s o = qsplitter_set_orientation s (int_of_orientation o)
  let orientation s =
    match qsplitter_orientation s with
    | 1 -> `Vertical
    | _ -> `Horizontal
  let set_sizes = qsplitter_set_sizes
  let sizes = qsplitter_sizes
  let set_stretch_factor s ~index ~stretch = qsplitter_set_stretch_factor s index stretch
end

(* ScrollArea *)
external qscrollarea_create : 'a Core.t option -> qscroll_area Core.t = "caml_oqt6_qscrollarea_create"
external qscrollarea_set_widget : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qscrollarea_set_widget"
external qscrollarea_widget : 'a Core.t -> qwidget Core.t option = "caml_oqt6_qscrollarea_widget"
external qscrollarea_set_widget_resizable : 'a Core.t -> bool -> unit = "caml_oqt6_qscrollarea_set_widget_resizable"
external qscrollarea_is_widget_resizable : 'a Core.t -> bool = "caml_oqt6_qscrollarea_is_widget_resizable"

module ScrollArea = struct
  let create ?parent () = qscrollarea_create parent
  let set_widget = qscrollarea_set_widget
  let widget = qscrollarea_widget
  let set_widget_resizable = qscrollarea_set_widget_resizable
  let is_widget_resizable = qscrollarea_is_widget_resizable
end

(* GroupBox *)
external qgroupbox_create : string option -> 'a Core.t option -> qgroup_box Core.t = "caml_oqt6_qgroupbox_create"
external qgroupbox_title : 'a Core.t -> string = "caml_oqt6_qgroupbox_title"
external qgroupbox_set_title : 'a Core.t -> string -> unit = "caml_oqt6_qgroupbox_set_title"
external qgroupbox_is_checkable : 'a Core.t -> bool = "caml_oqt6_qgroupbox_is_checkable"
external qgroupbox_set_checkable : 'a Core.t -> bool -> unit = "caml_oqt6_qgroupbox_set_checkable"
external qgroupbox_is_checked : 'a Core.t -> bool = "caml_oqt6_qgroupbox_is_checked"
external qgroupbox_set_checked : 'a Core.t -> bool -> unit = "caml_oqt6_qgroupbox_set_checked"
external qgroupbox_connect_toggled : 'a Core.t -> (bool -> unit) -> unit = "caml_oqt6_qgroupbox_connect_toggled"

module GroupBox = struct
  let create ?title ?parent () = qgroupbox_create title parent
  let title = qgroupbox_title
  let set_title = qgroupbox_set_title
  let is_checkable = qgroupbox_is_checkable
  let set_checkable = qgroupbox_set_checkable
  let is_checked = qgroupbox_is_checked
  let set_checked = qgroupbox_set_checked
  let on_toggled = qgroupbox_connect_toggled
end

(* ToolBar *)
external qtoolbar_create : string option -> 'a Core.t option -> qtool_bar Core.t = "caml_oqt6_qtoolbar_create"
external qtoolbar_add_action : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qtoolbar_add_action"
external qtoolbar_add_action_text : 'a Core.t -> string -> qaction Core.t = "caml_oqt6_qtoolbar_add_action_text"
external qtoolbar_add_widget : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qtoolbar_add_widget"
external qtoolbar_add_separator : 'a Core.t -> unit = "caml_oqt6_qtoolbar_add_separator"
external qtoolbar_set_movable : 'a Core.t -> bool -> unit = "caml_oqt6_qtoolbar_set_movable"
external qtoolbar_is_movable : 'a Core.t -> bool = "caml_oqt6_qtoolbar_is_movable"

module ToolBar = struct
  let create ?title ?parent () = qtoolbar_create title parent
  let add_action = qtoolbar_add_action
  let add_action_text = qtoolbar_add_action_text
  let add_widget = qtoolbar_add_widget
  let add_separator = qtoolbar_add_separator
  let set_movable = qtoolbar_set_movable
  let is_movable = qtoolbar_is_movable
end

(* DockWidget *)
external qdockwidget_create : string option -> 'a Core.t option -> qdock_widget Core.t = "caml_oqt6_qdockwidget_create"
external qdockwidget_set_widget : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qdockwidget_set_widget"
external qdockwidget_widget : 'a Core.t -> qwidget Core.t option = "caml_oqt6_qdockwidget_widget"

module DockWidget = struct
  let create ?title ?parent () = qdockwidget_create title parent
  let set_widget = qdockwidget_set_widget
  let widget = qdockwidget_widget
end

(* ColorDialog *)
external qcolordialog_get_color : 'a Core.t option -> Gui.Color.t option -> string option -> Gui.Color.t option = "caml_oqt6_qcolordialog_get_color"

module ColorDialog = struct
  let get_color ?parent ?initial ?title () = qcolordialog_get_color parent initial title
end

(* FontDialog *)
external qfontdialog_get_font : 'a Core.t option -> Gui.Font.t option -> string option -> Gui.Font.t option = "caml_oqt6_qfontdialog_get_font"

module FontDialog = struct
  let get_font ?parent ?initial ?title () = qfontdialog_get_font parent initial title
end

(* InputDialog *)
external qinputdialog_get_text : 'a Core.t option -> string -> string -> string option -> string option = "caml_oqt6_qinputdialog_get_text"
external qinputdialog_get_int : 'a Core.t option -> string -> string -> int option -> int option -> int option -> int option -> int option = "caml_oqt6_qinputdialog_get_int_byte" "caml_oqt6_qinputdialog_get_int"
external qinputdialog_get_item : 'a Core.t option -> string -> string -> string list -> int option -> bool option -> string option = "caml_oqt6_qinputdialog_get_item_byte" "caml_oqt6_qinputdialog_get_item"

module InputDialog = struct
  let get_text ?parent ~title ~label ?initial () = qinputdialog_get_text parent title label initial
  let get_int ?parent ~title ~label ?value ?min ?max ?step () = qinputdialog_get_int parent title label value min max step
  let get_item ?parent ~title ~label ~items ?current ?editable () = qinputdialog_get_item parent title label items current editable
end

(* ProgressDialog *)
external qprogressdialog_create : string -> string -> int -> int -> 'a Core.t option -> qprogress_dialog Core.t = "caml_oqt6_qprogressdialog_create"
external qprogressdialog_set_value : 'a Core.t -> int -> unit = "caml_oqt6_qprogressdialog_set_value"
external qprogressdialog_value : 'a Core.t -> int = "caml_oqt6_qprogressdialog_value"
external qprogressdialog_was_canceled : 'a Core.t -> bool = "caml_oqt6_qprogressdialog_was_canceled"
external qprogressdialog_cancel : 'a Core.t -> unit = "caml_oqt6_qprogressdialog_cancel"
external qprogressdialog_set_range : 'a Core.t -> int -> int -> unit = "caml_oqt6_qprogressdialog_set_range"

module ProgressDialog = struct
  let create ~label_text ~cancel_button_text ~min ~max ?parent () =
    qprogressdialog_create label_text cancel_button_text min max parent
  let set_value = qprogressdialog_set_value
  let value = qprogressdialog_value
  let was_canceled = qprogressdialog_was_canceled
  let cancel = qprogressdialog_cancel
  let set_range pd ~min ~max = qprogressdialog_set_range pd min max
end

