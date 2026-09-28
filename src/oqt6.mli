(** OQt6: Cross-Platform Qt 6 Bindings for OCaml

    OQt6 provides safe, type-checked, and idiomatic OCaml bindings for Qt 6,
    supporting both imperative widget construction and reactive declarative UIs. *)

(** {1 Core Modules} *)

module Core = Core
module Gui = Gui
module Widgets = Widgets

(** {1 Common Types} *)

type 'a t = 'a Core.t
type orientation = Widgets.orientation
type mouse_button = Widgets.mouse_button
type mouse_event = Widgets.mouse_event
type key_event = Widgets.key_event
type resize_event = Widgets.resize_event
type selection_behavior = Widgets.selection_behavior
type selection_mode = Widgets.selection_mode
type header_resize_mode = Widgets.header_resize_mode
type dock_area = Widgets.dock_area
type cursor_shape = Gui.Cursor.shape

(** {1 Core & Concurrency} *)

(** QObject memory management and lifetime tracking. *)
module Object = Core.Object

(** Low-overhead timers (single-shot and repeating). *)
module Timer = Core.Timer

(** {1 2D Vector Graphics & Styling} *)

(** RGB / RGBA color representations and color constants. *)
module Color = Gui.Color

(** Typography and font styling. *)
module Font = Gui.Font

(** Pen styles for outline drawing. *)
module Pen = Gui.Pen

(** Brush styles for area filling. *)
module Brush = Gui.Brush

(** 2D drawing primitives and affine transforms. *)
module Painter = Gui.Painter

(** In-memory pixel buffers and image file loading. *)
module Pixmap = Gui.Pixmap

(** Window and button icons (from files, pixmaps, or system themes). *)
module Icon = Gui.Icon

(** Mouse cursor shapes. *)
module Cursor = Gui.Cursor

(** {1 Standard Interactive Widgets} *)

(** Qt Application runtime and event loop control. *)
module App = Widgets.App

(** Base widget operations (resizing, visibility, stylesheets, subtyping). *)
module Widget = Widgets.Widget

(** Push buttons with text, icons, and click signals. *)
module Button = Widgets.Button

(** Two-state check boxes with toggle signals. *)
module CheckBox = Widgets.CheckBox

(** Radio buttons for mutually exclusive selections. *)
module RadioButton = Widgets.RadioButton

(** Drop-down selection boxes. *)
module ComboBox = Widgets.ComboBox

(** Numeric spin boxes with step, range, and prefix/suffix formatting. *)
module SpinBox = Widgets.SpinBox

(** Horizontal and vertical numeric sliders. *)
module Slider = Widgets.Slider

(** Visual progress indicators. *)
module ProgressBar = Widgets.ProgressBar

(** Multi-line rich or plain text editor. *)
module TextEdit = Widgets.TextEdit

(** Text display labels with word-wrapping. *)
module Label = Widgets.Label

(** Single-line text input with placeholder support. *)
module LineEdit = Widgets.LineEdit

(** Interactive 2D graphics canvas with event trampolines. *)
module Canvas = Widgets.Canvas

(** Box and grid layouts for widget arrangement. *)
module Layout = Widgets.Layout

(** {1 Top-Level Windows & Desktop Infrastructure} *)

(** Main application windows with menu bars, status bars, and docks. *)
module MainWindow = Widgets.MainWindow

(** Window menu bars. *)
module MenuBar = Widgets.MenuBar

(** Drop-down and context menus. *)
module Menu = Widgets.Menu

(** Command actions shareable between menus and toolbars. *)
module Action = Widgets.Action

(** Bottom-edge window status bars. *)
module StatusBar = Widgets.StatusBar

(** Base modal and modeless dialog windows. *)
module Dialog = Widgets.Dialog

(** Standard alert and confirmation dialogs. *)
module MessageBox = Widgets.MessageBox

(** Native file and directory picker dialogs. *)
module FileDialog = Widgets.FileDialog

(** {1 Model / View Architecture} *)

(** Imperative item-by-item table/tree model. *)
module StandardItemModel = Widgets.StandardItemModel

(** High-performance zero-copy functional table model. *)
module TableModel = Widgets.TableModel

(** Tabular data view with headers and sorting. *)
module TableView = Widgets.TableView

(** Hierarchical tree data view. *)
module TreeView = Widgets.TreeView

(** One-dimensional list data view. *)
module ListView = Widgets.ListView

(** Table and tree column/row header views. *)
module HeaderView = Widgets.HeaderView

(** View selection state and row selection management. *)
module ItemSelectionModel = Widgets.ItemSelectionModel

(** {1 Advanced Containers & Navigation} *)

(** Multi-page tabbed container with movable/closable tabs. *)
module TabWidget = Widgets.TabWidget

(** Multi-page widget stack (only one active page visible at a time). *)
module StackedWidget = Widgets.StackedWidget

(** Draggable horizontal and vertical splitter containers. *)
module Splitter = Widgets.Splitter

(** Scrollable viewports for large widget trees. *)
module ScrollArea = Widgets.ScrollArea

(** Titled group panels with optional checkable checkboxes. *)
module GroupBox = Widgets.GroupBox

(** Desktop toolbars with action buttons and separators. *)
module ToolBar = Widgets.ToolBar

(** Dockable and detachable desktop panels. *)
module DockWidget = Widgets.DockWidget

(** Native color selection dialog. *)
module ColorDialog = Widgets.ColorDialog

(** Native font selection dialog. *)
module FontDialog = Widgets.FontDialog

(** Modal text, integer, and item input dialogs. *)
module InputDialog = Widgets.InputDialog

(** Responsive operation progress dialog with abort support. *)
module ProgressDialog = Widgets.ProgressDialog

(** {1 Declarative & Reactive UI Framework} *)

(** Declarative component tree combinators ([vbox], [hbox], [button], [cond], etc.). *)
module Dsl = Dsl

(** Reactive signals and state management. *)
module State = Dsl.State
