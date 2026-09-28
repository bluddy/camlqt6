(** OQt6: Qt 6 bindings for OCaml *)

module Core = Core
module Gui = Gui
module Widgets = Widgets

type 'a t = 'a Core.t
type orientation = Widgets.orientation

module Object = Core.Object
module Timer = Core.Timer

module App = Widgets.App
module Widget = Widgets.Widget
module Button = Widgets.Button
module CheckBox = Widgets.CheckBox
module RadioButton = Widgets.RadioButton
module ComboBox = Widgets.ComboBox
module SpinBox = Widgets.SpinBox
module Slider = Widgets.Slider
module ProgressBar = Widgets.ProgressBar
module TextEdit = Widgets.TextEdit
module Label = Widgets.Label
module LineEdit = Widgets.LineEdit
module Layout = Widgets.Layout

module MainWindow = Widgets.MainWindow
module MenuBar = Widgets.MenuBar
module Menu = Widgets.Menu
module Action = Widgets.Action
module StatusBar = Widgets.StatusBar
module Dialog = Widgets.Dialog
module MessageBox = Widgets.MessageBox
module FileDialog = Widgets.FileDialog
