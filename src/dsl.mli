(** OQt6 DSL: Declarative and Reactive UI Framework for Qt 6 *)

module State : sig
  type 'a t

  val create : 'a -> 'a t
  val get : 'a t -> 'a
  val set : 'a t -> 'a -> unit
  val update : 'a t -> ('a -> 'a) -> unit
  val subscribe : 'a t -> ('a -> unit) -> unit
  val map : ('a -> 'b) -> 'a t -> 'b t
  val map2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
end

type node

(** {1 Layouts & Containers} *)

val vbox : ?spacing:int -> ?margin:int -> ?style:string -> node list -> node
val hbox : ?spacing:int -> ?margin:int -> ?style:string -> node list -> node
val grid : ?spacing:int -> ?margin:int -> (int * int * node) list -> node
val split : ?orientation:Widgets.orientation -> ?sizes:int list -> node list -> node
val tabs : (string * node) list -> node
val scroll : ?resizable:bool -> node -> node
val group : ?title:string -> ?checkable:bool -> ?checked:bool State.t -> node -> node
val spacing : int -> node
val stretch : ?factor:int -> unit -> node

(** {1 Reactive Control Flow} *)

val cond : bool State.t -> true_node:node -> false_node:node -> node
val match_s : int State.t -> node list -> node

(** {1 Widgets} *)

val label : ?style:string -> string -> node
val label_s : ?style:string -> string State.t -> node
val button : ?icon:Gui.Icon.t -> ?style:string -> ?enabled_s:bool State.t -> ?on_click:(unit -> unit) -> string -> node
val button_s : ?icon:Gui.Icon.t -> ?style:string -> ?enabled_s:bool State.t -> ?on_click:(unit -> unit) -> string State.t -> node
val check_box : ?checked:bool State.t -> ?on_toggled:(bool -> unit) -> string -> node
val radio_button : ?checked:bool State.t -> ?on_toggled:(bool -> unit) -> string -> node
val line_edit : ?placeholder:string -> ?text:string State.t -> ?on_change:(string -> unit) -> unit -> node
val text_edit : ?read_only:bool -> ?style:string -> ?text:string State.t -> ?on_change:(string -> unit) -> unit -> node
val slider : ?min:int -> ?max:int -> ?orientation:Widgets.orientation -> ?value:int State.t -> ?on_change:(int -> unit) -> unit -> node
val spin_box : ?min:int -> ?max:int -> ?prefix:string -> ?suffix:string -> ?value:int State.t -> ?on_change:(int -> unit) -> unit -> node
val progress_bar : ?min:int -> ?max:int -> ?value:int State.t -> ?format:string -> unit -> node
val combo_box : items:string list -> ?current:int State.t -> ?on_change:(int -> unit) -> unit -> node
val canvas : ?width:int -> ?height:int -> on_paint:(Gui.Painter.t -> unit) -> ?on_mouse_move:(Widgets.mouse_event -> unit) -> ?on_mouse_press:(Widgets.mouse_event -> unit) -> ?on_mouse_release:(Widgets.mouse_event -> unit) -> ?on_key_press:(Widgets.key_event -> unit) -> unit -> node
val custom : (parent:Widgets.qwidget Core.t option -> Widgets.qwidget Core.t) -> node

(** {1 Top-Level Window & Application Runner} *)

val window : ?title:string -> ?width:int -> ?height:int -> ?status_bar:string State.t -> node -> node
val mount : ?parent:Widgets.qwidget Core.t -> node -> Widgets.qwidget Core.t
val run : ?args:string array -> ?title:string -> ?width:int -> ?height:int -> node -> int
