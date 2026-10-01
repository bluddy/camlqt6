(** Qt 6 Widgets module *)

type orientation = [ `Horizontal | `Vertical ]
type selection_behavior = [ `Select_items | `Select_rows | `Select_columns ]
type selection_mode = [ `No_selection | `Single_selection | `Multi_selection | `Extended_selection | `Contiguous_selection ]
type header_resize_mode = [ `Interactive | `Stretch | `Fixed | `Resize_to_contents ]

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

type qabstract_item_view = [ qwidget | `QAbstractItemView ]
type qtable_view = [ qabstract_item_view | `QTableView ]
type qtree_view = [ qabstract_item_view | `QTreeView ]
type qlist_view = [ qabstract_item_view | `QListView ]
type qheader_view = [ qwidget | `QHeaderView ]
type qitem_selection_model = [ Core.qobject | `QItemSelectionModel ]

type dock_area = [ `Left_dock | `Right_dock | `Top_dock | `Bottom_dock ]
type qtab_widget = [ qwidget | `QTabWidget ]
type qstacked_widget = [ qwidget | `QStackedWidget ]
type qsplitter = [ qwidget | `QSplitter ]
type qscroll_area = [ qwidget | `QScrollArea ]
type qgroup_box = [ qwidget | `QGroupBox ]
type qtool_bar = [ qwidget | `QToolBar ]
type qdock_widget = [ qwidget | `QDockWidget ]
type qprogress_dialog = [ qdialog | `QProgressDialog ]

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
  val update : [> `QWidget ] Core.t -> unit
  val set_mouse_tracking : [> `QWidget ] Core.t -> bool -> unit
  val set_accept_drops : [> `QWidget ] Core.t -> bool -> unit
  val accept_drops : [> `QWidget ] Core.t -> bool
  val as_widget : [> `QWidget ] Core.t -> qwidget Core.t
end

module Button : sig
  val create : ?text:string -> ?parent:[> `QWidget ] Core.t -> unit -> qpush_button Core.t
  val set_text : [> `QPushButton ] Core.t -> string -> unit
  val text : [> `QPushButton ] Core.t -> string
  val set_icon : [> `QPushButton ] Core.t -> Gui.Icon.t -> unit
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

module Canvas : sig
  val create : ?parent:[> `QWidget ] Core.t -> unit -> qcanvas Core.t
  val on_paint : [> `QCanvas ] Core.t -> (Gui.Painter.t -> unit) -> unit
  val on_mouse_press : [> `QCanvas ] Core.t -> (mouse_event -> unit) -> unit
  val on_mouse_release : [> `QCanvas ] Core.t -> (mouse_event -> unit) -> unit
  val on_mouse_move : [> `QCanvas ] Core.t -> (mouse_event -> unit) -> unit
  val on_key_press : [> `QCanvas ] Core.t -> (key_event -> unit) -> unit
  val on_resize : [> `QCanvas ] Core.t -> (resize_event -> unit) -> unit
  val update : [> `QCanvas ] Core.t -> unit
  val set_mouse_tracking : [> `QCanvas ] Core.t -> bool -> unit
  val on_drag_enter : [> `QCanvas ] Core.t -> (x:int -> y:int -> Gui.MimeData.t -> bool) -> unit
  val on_drag_move : [> `QCanvas ] Core.t -> (x:int -> y:int -> Gui.MimeData.t -> bool) -> unit
  val on_drag_leave : [> `QCanvas ] Core.t -> (unit -> unit) -> unit
  val on_drop : [> `QCanvas ] Core.t -> (x:int -> y:int -> Gui.MimeData.t -> unit) -> unit
end

module MainWindow : sig
  val create : ?parent:[> `QWidget ] Core.t -> unit -> qmain_window Core.t
  val set_central_widget : [> `QMainWindow ] Core.t -> [> `QWidget ] Core.t -> unit
  val central_widget : [> `QMainWindow ] Core.t -> qwidget Core.t option
  val menu_bar : [> `QMainWindow ] Core.t -> qmenu_bar Core.t
  val status_bar : [> `QMainWindow ] Core.t -> qstatus_bar Core.t
  val set_status_bar : [> `QMainWindow ] Core.t -> [> `QStatusBar ] Core.t -> unit
  val set_window_icon : [> `QMainWindow ] Core.t -> Gui.Icon.t -> unit
  val add_tool_bar : [> `QMainWindow ] Core.t -> [> `QToolBar ] Core.t -> unit
  val add_tool_bar_title : [> `QMainWindow ] Core.t -> string -> qtool_bar Core.t
  val add_dock_widget : [> `QMainWindow ] Core.t -> dock_area -> [> `QDockWidget ] Core.t -> unit
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
  val set_icon : [> `QAction ] Core.t -> Gui.Icon.t -> unit
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
  val set_spacing : [> `QLayout ] Core.t -> int -> unit
  val set_contents_margins : [> `QLayout ] Core.t -> left:int -> top:int -> right:int -> bottom:int -> unit
  val set_margin : [> `QLayout ] Core.t -> int -> unit
end

module ItemSelectionModel : sig
  val clear_selection : [> `QItemSelectionModel ] Core.t -> unit
  val has_selection : [> `QItemSelectionModel ] Core.t -> bool
  val selected_rows : [> `QItemSelectionModel ] Core.t -> int list
  val current_row : [> `QItemSelectionModel ] Core.t -> int
  val current_column : [> `QItemSelectionModel ] Core.t -> int
  val on_selection_changed : [> `QItemSelectionModel ] Core.t -> (unit -> unit) -> unit
  val on_current_changed : [> `QItemSelectionModel ] Core.t -> (int -> int -> unit) -> unit
end

module HeaderView : sig
  val set_stretch_last_section : [> `QHeaderView ] Core.t -> bool -> unit
  val is_stretch_last_section : [> `QHeaderView ] Core.t -> bool
  val set_section_resize_mode : [> `QHeaderView ] Core.t -> ?section:int -> header_resize_mode -> unit
end

module StandardItemModel : sig
  val create : ?rows:int -> ?cols:int -> ?parent:[> `QObject ] Core.t -> unit -> qstandard_item_model Core.t
  val set_item : [> `QStandardItemModel ] Core.t -> row:int -> col:int -> text:string -> unit
  val item_text : [> `QStandardItemModel ] Core.t -> row:int -> col:int -> string
  val set_horizontal_header_labels : [> `QStandardItemModel ] Core.t -> string list -> unit
  val set_vertical_header_labels : [> `QStandardItemModel ] Core.t -> string list -> unit
  val row_count : [> `QStandardItemModel ] Core.t -> int
  val column_count : [> `QStandardItemModel ] Core.t -> int
  val clear : [> `QStandardItemModel ] Core.t -> unit
  val append_row : [> `QStandardItemModel ] Core.t -> string list -> unit
  val remove_row : [> `QStandardItemModel ] Core.t -> int -> unit
  val remove_column : [> `QStandardItemModel ] Core.t -> int -> unit
end

module TableModel : sig
  val create :
    ?parent:[> `QObject ] Core.t ->
    row_count:(unit -> int) ->
    col_count:(unit -> int) ->
    data:(int -> int -> string) ->
    ?header_data:(int -> orientation -> string) ->
    unit -> qocaml_table_model Core.t

  val notify_reset : [> `QOCamlTableModel ] Core.t -> unit
  val notify_data_changed : [> `QOCamlTableModel ] Core.t -> top_row:int -> left_col:int -> bottom_row:int -> right_col:int -> unit
end

module TableView : sig
  val create : ?parent:[> `QWidget ] Core.t -> unit -> qtable_view Core.t
  val set_model : [> `QTableView ] Core.t -> [> `QAbstractItemModel ] Core.t -> unit
  val set_selection_behavior : [> `QTableView ] Core.t -> selection_behavior -> unit
  val set_selection_mode : [> `QTableView ] Core.t -> selection_mode -> unit
  val set_sorting_enabled : [> `QTableView ] Core.t -> bool -> unit
  val set_show_grid : [> `QTableView ] Core.t -> bool -> unit
  val set_alternating_row_colors : [> `QTableView ] Core.t -> bool -> unit
  val resize_columns_to_contents : [> `QTableView ] Core.t -> unit
  val resize_rows_to_contents : [> `QTableView ] Core.t -> unit
  val horizontal_header : [> `QTableView ] Core.t -> qheader_view Core.t
  val vertical_header : [> `QTableView ] Core.t -> qheader_view Core.t
  val selection_model : [> `QTableView ] Core.t -> qitem_selection_model Core.t
  val on_clicked : [> `QTableView ] Core.t -> (int -> int -> unit) -> unit
  val on_double_clicked : [> `QTableView ] Core.t -> (int -> int -> unit) -> unit
end

module TreeView : sig
  val create : ?parent:[> `QWidget ] Core.t -> unit -> qtree_view Core.t
  val set_model : [> `QTreeView ] Core.t -> [> `QAbstractItemModel ] Core.t -> unit
  val set_selection_behavior : [> `QTreeView ] Core.t -> selection_behavior -> unit
  val set_selection_mode : [> `QTreeView ] Core.t -> selection_mode -> unit
  val set_sorting_enabled : [> `QTreeView ] Core.t -> bool -> unit
  val set_alternating_row_colors : [> `QTreeView ] Core.t -> bool -> unit
  val expand_all : [> `QTreeView ] Core.t -> unit
  val collapse_all : [> `QTreeView ] Core.t -> unit
  val header : [> `QTreeView ] Core.t -> qheader_view Core.t
  val selection_model : [> `QTreeView ] Core.t -> qitem_selection_model Core.t
  val on_clicked : [> `QTreeView ] Core.t -> (int -> int -> unit) -> unit
end

module ListView : sig
  val create : ?parent:[> `QWidget ] Core.t -> unit -> qlist_view Core.t
  val set_model : [> `QListView ] Core.t -> [> `QAbstractItemModel ] Core.t -> unit
  val set_selection_behavior : [> `QListView ] Core.t -> selection_behavior -> unit
  val set_selection_mode : [> `QListView ] Core.t -> selection_mode -> unit
  val selection_model : [> `QListView ] Core.t -> qitem_selection_model Core.t
  val on_clicked : [> `QListView ] Core.t -> (int -> unit) -> unit
end

module TabWidget : sig
  val create : ?parent:[> `QWidget ] Core.t -> unit -> qtab_widget Core.t
  val add_tab : [> `QTabWidget ] Core.t -> label:string -> [> `QWidget ] Core.t -> int
  val insert_tab : [> `QTabWidget ] Core.t -> index:int -> label:string -> [> `QWidget ] Core.t -> int
  val remove_tab : [> `QTabWidget ] Core.t -> int -> unit
  val current_index : [> `QTabWidget ] Core.t -> int
  val set_current_index : [> `QTabWidget ] Core.t -> int -> unit
  val count : [> `QTabWidget ] Core.t -> int
  val tab_text : [> `QTabWidget ] Core.t -> int -> string
  val set_tab_text : [> `QTabWidget ] Core.t -> int -> string -> unit
  val set_tabs_closable : [> `QTabWidget ] Core.t -> bool -> unit
  val set_movable : [> `QTabWidget ] Core.t -> bool -> unit
  val set_tab_icon : [> `QTabWidget ] Core.t -> int -> Gui.Icon.t -> unit
  val on_current_changed : [> `QTabWidget ] Core.t -> (int -> unit) -> unit
  val on_tab_close_requested : [> `QTabWidget ] Core.t -> (int -> unit) -> unit
end

module StackedWidget : sig
  val create : ?parent:[> `QWidget ] Core.t -> unit -> qstacked_widget Core.t
  val add_widget : [> `QStackedWidget ] Core.t -> [> `QWidget ] Core.t -> int
  val remove_widget : [> `QStackedWidget ] Core.t -> [> `QWidget ] Core.t -> unit
  val current_index : [> `QStackedWidget ] Core.t -> int
  val set_current_index : [> `QStackedWidget ] Core.t -> int -> unit
  val count : [> `QStackedWidget ] Core.t -> int
  val on_current_changed : [> `QStackedWidget ] Core.t -> (int -> unit) -> unit
end

module Splitter : sig
  val create : ?orientation:orientation -> ?parent:[> `QWidget ] Core.t -> unit -> qsplitter Core.t
  val add_widget : [> `QSplitter ] Core.t -> [> `QWidget ] Core.t -> unit
  val set_orientation : [> `QSplitter ] Core.t -> orientation -> unit
  val orientation : [> `QSplitter ] Core.t -> orientation
  val set_sizes : [> `QSplitter ] Core.t -> int list -> unit
  val sizes : [> `QSplitter ] Core.t -> int list
  val set_stretch_factor : [> `QSplitter ] Core.t -> index:int -> stretch:int -> unit
end

module ScrollArea : sig
  val create : ?parent:[> `QWidget ] Core.t -> unit -> qscroll_area Core.t
  val set_widget : [> `QScrollArea ] Core.t -> [> `QWidget ] Core.t -> unit
  val widget : [> `QScrollArea ] Core.t -> qwidget Core.t option
  val set_widget_resizable : [> `QScrollArea ] Core.t -> bool -> unit
  val is_widget_resizable : [> `QScrollArea ] Core.t -> bool
end

module GroupBox : sig
  val create : ?title:string -> ?parent:[> `QWidget ] Core.t -> unit -> qgroup_box Core.t
  val title : [> `QGroupBox ] Core.t -> string
  val set_title : [> `QGroupBox ] Core.t -> string -> unit
  val is_checkable : [> `QGroupBox ] Core.t -> bool
  val set_checkable : [> `QGroupBox ] Core.t -> bool -> unit
  val is_checked : [> `QGroupBox ] Core.t -> bool
  val set_checked : [> `QGroupBox ] Core.t -> bool -> unit
  val on_toggled : [> `QGroupBox ] Core.t -> (bool -> unit) -> unit
end

module ToolBar : sig
  val create : ?title:string -> ?parent:[> `QWidget ] Core.t -> unit -> qtool_bar Core.t
  val add_action : [> `QToolBar ] Core.t -> [> `QAction ] Core.t -> unit
  val add_action_text : [> `QToolBar ] Core.t -> string -> qaction Core.t
  val add_widget : [> `QToolBar ] Core.t -> [> `QWidget ] Core.t -> unit
  val add_separator : [> `QToolBar ] Core.t -> unit
  val set_movable : [> `QToolBar ] Core.t -> bool -> unit
  val is_movable : [> `QToolBar ] Core.t -> bool
end

module DockWidget : sig
  val create : ?title:string -> ?parent:[> `QWidget ] Core.t -> unit -> qdock_widget Core.t
  val set_widget : [> `QDockWidget ] Core.t -> [> `QWidget ] Core.t -> unit
  val widget : [> `QDockWidget ] Core.t -> qwidget Core.t option
end

module ColorDialog : sig
  val get_color : ?parent:[> `QWidget ] Core.t -> ?initial:Gui.Color.t -> ?title:string -> unit -> Gui.Color.t option
end

module FontDialog : sig
  val get_font : ?parent:[> `QWidget ] Core.t -> ?initial:Gui.Font.t -> ?title:string -> unit -> Gui.Font.t option
end

module InputDialog : sig
  val get_text : ?parent:[> `QWidget ] Core.t -> title:string -> label:string -> ?initial:string -> unit -> string option
  val get_int : ?parent:[> `QWidget ] Core.t -> title:string -> label:string -> ?value:int -> ?min:int -> ?max:int -> ?step:int -> unit -> int option
  val get_item : ?parent:[> `QWidget ] Core.t -> title:string -> label:string -> items:string list -> ?current:int -> ?editable:bool -> unit -> string option
end

module ProgressDialog : sig
  val create : label_text:string -> cancel_button_text:string -> min:int -> max:int -> ?parent:[> `QWidget ] Core.t -> unit -> qprogress_dialog Core.t
  val set_value : [> `QProgressDialog ] Core.t -> int -> unit
  val value : [> `QProgressDialog ] Core.t -> int
  val was_canceled : [> `QProgressDialog ] Core.t -> bool
  val cancel : [> `QProgressDialog ] Core.t -> unit
  val set_range : [> `QProgressDialog ] Core.t -> min:int -> max:int -> unit
end
