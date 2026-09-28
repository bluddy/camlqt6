type orientation = [ `Horizontal | `Vertical ]

let int_of_orientation = function
  | `Horizontal -> 0
  | `Vertical -> 1

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
type qmain_window = [ qwidget | `QMainWindow ]
type qmenu_bar = [ qwidget | `QMenuBar ]
type qmenu = [ qwidget | `QMenu ]
type qaction = [ Core.qobject | `QAction ]
type qstatus_bar = [ qwidget | `QStatusBar ]
type qdialog = [ qwidget | `QDialog ]
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

(* MainWindow *)
external qmainwindow_create : 'a Core.t option -> qmain_window Core.t = "caml_oqt6_qmainwindow_create"
external qmainwindow_set_central_widget : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qmainwindow_set_central_widget"
external qmainwindow_central_widget : 'a Core.t -> qwidget Core.t option = "caml_oqt6_qmainwindow_central_widget"
external qmainwindow_menu_bar : 'a Core.t -> qmenu_bar Core.t = "caml_oqt6_qmainwindow_menu_bar"
external qmainwindow_status_bar : 'a Core.t -> qstatus_bar Core.t = "caml_oqt6_qmainwindow_status_bar"
external qmainwindow_set_status_bar : 'a Core.t -> 'b Core.t -> unit = "caml_oqt6_qmainwindow_set_status_bar"

module MainWindow = struct
  let create ?parent () = qmainwindow_create parent
  let set_central_widget = qmainwindow_set_central_widget
  let central_widget = qmainwindow_central_widget
  let menu_bar = qmainwindow_menu_bar
  let status_bar = qmainwindow_status_bar
  let set_status_bar = qmainwindow_set_status_bar
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
