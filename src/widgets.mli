(** Qt 6 Widgets module *)

type orientation = [ `Horizontal | `Vertical ]

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

module CheckBox : sig
  val create : ?text:string -> ?parent:[> `QWidget ] Core.t -> unit -> qcheck_box Core.t
  val set_checked : [> `QCheckBox ] Core.t -> bool -> unit
  val is_checked : [> `QCheckBox ] Core.t -> bool
  val set_text : [> `QCheckBox ] Core.t -> string -> unit
  val text : [> `QCheckBox ] Core.t -> string
  val on_toggled : [> `QCheckBox ] Core.t -> (bool -> unit) -> unit
end

module RadioButton : sig
  val create : ?text:string -> ?parent:[> `QWidget ] Core.t -> unit -> qradio_button Core.t
  val set_checked : [> `QRadioButton ] Core.t -> bool -> unit
  val is_checked : [> `QRadioButton ] Core.t -> bool
  val set_text : [> `QRadioButton ] Core.t -> string -> unit
  val text : [> `QRadioButton ] Core.t -> string
  val on_toggled : [> `QRadioButton ] Core.t -> (bool -> unit) -> unit
end

module ComboBox : sig
  val create : ?parent:[> `QWidget ] Core.t -> unit -> qcombo_box Core.t
  val add_item : [> `QComboBox ] Core.t -> string -> unit
  val add_items : [> `QComboBox ] Core.t -> string list -> unit
  val count : [> `QComboBox ] Core.t -> int
  val current_index : [> `QComboBox ] Core.t -> int
  val set_current_index : [> `QComboBox ] Core.t -> int -> unit
  val current_text : [> `QComboBox ] Core.t -> string
  val item_text : [> `QComboBox ] Core.t -> int -> string
  val clear : [> `QComboBox ] Core.t -> unit
  val on_current_index_changed : [> `QComboBox ] Core.t -> (int -> unit) -> unit
  val on_current_text_changed : [> `QComboBox ] Core.t -> (string -> unit) -> unit
end

module SpinBox : sig
  val create : ?parent:[> `QWidget ] Core.t -> unit -> qspin_box Core.t
  val value : [> `QSpinBox ] Core.t -> int
  val set_value : [> `QSpinBox ] Core.t -> int -> unit
  val set_minimum : [> `QSpinBox ] Core.t -> int -> unit
  val set_maximum : [> `QSpinBox ] Core.t -> int -> unit
  val set_range : [> `QSpinBox ] Core.t -> min:int -> max:int -> unit
  val set_single_step : [> `QSpinBox ] Core.t -> int -> unit
  val set_prefix : [> `QSpinBox ] Core.t -> string -> unit
  val set_suffix : [> `QSpinBox ] Core.t -> string -> unit
  val on_value_changed : [> `QSpinBox ] Core.t -> (int -> unit) -> unit
end

module Slider : sig
  val create : ?orientation:orientation -> ?parent:[> `QWidget ] Core.t -> unit -> qslider Core.t
  val value : [> `QSlider ] Core.t -> int
  val set_value : [> `QSlider ] Core.t -> int -> unit
  val set_minimum : [> `QSlider ] Core.t -> int -> unit
  val set_maximum : [> `QSlider ] Core.t -> int -> unit
  val set_range : [> `QSlider ] Core.t -> min:int -> max:int -> unit
  val set_single_step : [> `QSlider ] Core.t -> int -> unit
  val set_orientation : [> `QSlider ] Core.t -> orientation -> unit
  val on_value_changed : [> `QSlider ] Core.t -> (int -> unit) -> unit
end

module ProgressBar : sig
  val create : ?parent:[> `QWidget ] Core.t -> unit -> qprogress_bar Core.t
  val value : [> `QProgressBar ] Core.t -> int
  val set_value : [> `QProgressBar ] Core.t -> int -> unit
  val set_minimum : [> `QProgressBar ] Core.t -> int -> unit
  val set_maximum : [> `QProgressBar ] Core.t -> int -> unit
  val set_range : [> `QProgressBar ] Core.t -> min:int -> max:int -> unit
  val set_format : [> `QProgressBar ] Core.t -> string -> unit
  val reset : [> `QProgressBar ] Core.t -> unit
end

module TextEdit : sig
  val create : ?text:string -> ?parent:[> `QWidget ] Core.t -> unit -> qtext_edit Core.t
  val to_plain_text : [> `QTextEdit ] Core.t -> string
  val set_plain_text : [> `QTextEdit ] Core.t -> string -> unit
  val to_html : [> `QTextEdit ] Core.t -> string
  val set_html : [> `QTextEdit ] Core.t -> string -> unit
  val append : [> `QTextEdit ] Core.t -> string -> unit
  val clear : [> `QTextEdit ] Core.t -> unit
  val set_read_only : [> `QTextEdit ] Core.t -> bool -> unit
  val is_read_only : [> `QTextEdit ] Core.t -> bool
  val on_text_changed : [> `QTextEdit ] Core.t -> (unit -> unit) -> unit
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

module MainWindow : sig
  val create : ?parent:[> `QWidget ] Core.t -> unit -> qmain_window Core.t
  val set_central_widget : [> `QMainWindow ] Core.t -> [> `QWidget ] Core.t -> unit
  val central_widget : [> `QMainWindow ] Core.t -> qwidget Core.t option
  val menu_bar : [> `QMainWindow ] Core.t -> qmenu_bar Core.t
  val status_bar : [> `QMainWindow ] Core.t -> qstatus_bar Core.t
  val set_status_bar : [> `QMainWindow ] Core.t -> [> `QStatusBar ] Core.t -> unit
end

module MenuBar : sig
  val add_menu : [> `QMenuBar ] Core.t -> string -> qmenu Core.t
  val add_action : [> `QMenuBar ] Core.t -> [> `QAction ] Core.t -> unit
  val clear : [> `QMenuBar ] Core.t -> unit
end

module Menu : sig
  val add_action : [> `QMenu ] Core.t -> [> `QAction ] Core.t -> unit
  val add_menu : [> `QMenu ] Core.t -> [> `QMenu ] Core.t -> unit
  val add_action_text : [> `QMenu ] Core.t -> string -> qaction Core.t
  val add_separator : [> `QMenu ] Core.t -> unit
  val clear : [> `QMenu ] Core.t -> unit
end

module Action : sig
  val create : ?text:string -> ?parent:[> `QObject ] Core.t -> unit -> qaction Core.t
  val set_text : [> `QAction ] Core.t -> string -> unit
  val text : [> `QAction ] Core.t -> string
  val set_checkable : [> `QAction ] Core.t -> bool -> unit
  val is_checkable : [> `QAction ] Core.t -> bool
  val set_checked : [> `QAction ] Core.t -> bool -> unit
  val is_checked : [> `QAction ] Core.t -> bool
  val set_enabled : [> `QAction ] Core.t -> bool -> unit
  val is_enabled : [> `QAction ] Core.t -> bool
  val set_shortcut : [> `QAction ] Core.t -> string -> unit
  val on_triggered : [> `QAction ] Core.t -> (bool -> unit) -> unit
end

module StatusBar : sig
  val show_message : [> `QStatusBar ] Core.t -> ?timeout:int -> string -> unit
  val clear_message : [> `QStatusBar ] Core.t -> unit
  val current_message : [> `QStatusBar ] Core.t -> string
end

module Dialog : sig
  val create : ?parent:[> `QWidget ] Core.t -> unit -> qdialog Core.t
  val exec : [> `QDialog ] Core.t -> int
  val accept : [> `QDialog ] Core.t -> unit
  val reject : [> `QDialog ] Core.t -> unit
  val set_modal : [> `QDialog ] Core.t -> bool -> unit
  val is_modal : [> `QDialog ] Core.t -> bool
end

module MessageBox : sig
  val information : ?parent:[> `QWidget ] Core.t -> title:string -> text:string -> unit -> unit
  val warning : ?parent:[> `QWidget ] Core.t -> title:string -> text:string -> unit -> unit
  val critical : ?parent:[> `QWidget ] Core.t -> title:string -> text:string -> unit -> unit
  val question : ?parent:[> `QWidget ] Core.t -> title:string -> text:string -> unit -> bool
end

module FileDialog : sig
  val get_open_file_name : ?parent:[> `QWidget ] Core.t -> ?caption:string -> ?dir:string -> ?filter:string -> unit -> string option
  val get_save_file_name : ?parent:[> `QWidget ] Core.t -> ?caption:string -> ?dir:string -> ?filter:string -> unit -> string option
  val get_existing_directory : ?parent:[> `QWidget ] Core.t -> ?caption:string -> ?dir:string -> unit -> string option
end

module Layout : sig
  module VBox : sig
    val create : ?parent:[> `QWidget ] Core.t -> unit -> qvbox_layout Core.t
  end

  module HBox : sig
    val create : ?parent:[> `QWidget ] Core.t -> unit -> qhbox_layout Core.t
  end

  module Grid : sig
    val create : ?parent:[> `QWidget ] Core.t -> unit -> qgrid_layout Core.t
    val add_widget : [> `QGridLayout ] Core.t -> row:int -> col:int -> ?row_span:int -> ?col_span:int -> [> `QWidget ] Core.t -> unit
    val add_layout : [> `QGridLayout ] Core.t -> row:int -> col:int -> ?row_span:int -> ?col_span:int -> [> `QLayout ] Core.t -> unit
    val set_row_stretch : [> `QGridLayout ] Core.t -> row:int -> stretch:int -> unit
    val set_column_stretch : [> `QGridLayout ] Core.t -> col:int -> stretch:int -> unit
    val set_spacing : [> `QGridLayout ] Core.t -> int -> unit
  end

  val add_widget : [> `QBoxLayout ] Core.t -> ?stretch:int -> [> `QWidget ] Core.t -> unit
  val add_layout : [> `QBoxLayout ] Core.t -> ?stretch:int -> [> `QLayout ] Core.t -> unit
  val add_stretch : [> `QBoxLayout ] Core.t -> ?stretch:int -> unit -> unit
  val add_spacing : [> `QBoxLayout ] Core.t -> int -> unit
end
