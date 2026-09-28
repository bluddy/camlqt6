(** OQt6 DSL: Declarative and Reactive UI Framework for Qt 6 *)

(** Reactive state management and signals. *)
module State : sig
  (** A reactive value container that notifies subscribers when modified. *)
  type 'a t

  (** [create initial] creates a new reactive state with the given initial value. *)
  val create : 'a -> 'a t

  (** [get state] retrieves the current value of the state. *)
  val get : 'a t -> 'a

  (** [set state new_value] updates the state and notifies all subscribers if [new_value <> current_value]. *)
  val set : 'a t -> 'a -> unit

  (** [update state f] updates the state by applying [f] to the current value. *)
  val update : 'a t -> ('a -> 'a) -> unit

  (** [subscribe state f] registers a listener [f]. [f] is called immediately with the current value
      and subsequently whenever the value changes. *)
  val subscribe : 'a t -> ('a -> unit) -> unit

  (** [map f state] creates a derived state whose value is always [f (State.get state)]. *)
  val map : ('a -> 'b) -> 'a t -> 'b t

  (** [map2 f s1 s2] creates a derived state whose value is computed from two independent states. *)
  val map2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
end

(** A declarative UI node specification. *)
type node

(** {1 Layouts & Containers} *)

(** [vbox ?spacing ?margin ?style children] creates a vertical box container. *)
val vbox : ?spacing:int -> ?margin:int -> ?style:string -> node list -> node

(** [hbox ?spacing ?margin ?style children] creates a horizontal box container. *)
val hbox : ?spacing:int -> ?margin:int -> ?style:string -> node list -> node

(** [grid ?spacing ?margin [(row, col, child); ...]] creates a 2D grid layout. *)
val grid : ?spacing:int -> ?margin:int -> (int * int * node) list -> node

(** [split ?orientation ?sizes children] creates a draggable splitter container. *)
val split : ?orientation:Widgets.orientation -> ?sizes:int list -> node list -> node

(** [tabs [("Title", page); ...]] creates a multi-page tabbed container. *)
val tabs : (string * node) list -> node

(** [scroll ?resizable child] wraps [child] in a scrollable viewport. *)
val scroll : ?resizable:bool -> node -> node

(** [group ?title ?checkable ?checked child] creates a titled group panel. *)
val group : ?title:string -> ?checkable:bool -> ?checked:bool State.t -> node -> node

(** [spacing pixels] adds fixed empty spacing inside a box layout. *)
val spacing : int -> node

(** [stretch ?factor ()] adds an expanding stretch space inside a box layout. *)
val stretch : ?factor:int -> unit -> node

(** {1 Reactive Control Flow} *)

(** [cond bool_state ~true_node ~false_node] dynamically toggles between two UI subtrees
    without layout recomputation or screen flicker, backed by a [QStackedWidget]. *)
val cond : bool State.t -> true_node:node -> false_node:node -> node

(** [match_s int_state pages] dynamically selects the active page from [pages] matching [int_state]. *)
val match_s : int State.t -> node list -> node

(** {1 Widgets} *)

(** [label ?style text] creates a static text label. *)
val label : ?style:string -> string -> node

(** [label_s ?style state] creates a reactive label whose text automatically updates with [state]. *)
val label_s : ?style:string -> string State.t -> node

(** [button ?icon ?style ?enabled_s ?on_click text] creates a push button. *)
val button : ?icon:Gui.Icon.t -> ?style:string -> ?enabled_s:bool State.t -> ?on_click:(unit -> unit) -> string -> node

(** [button_s ?icon ?style ?enabled_s ?on_click state] creates a button whose label automatically reflects [state]. *)
val button_s : ?icon:Gui.Icon.t -> ?style:string -> ?enabled_s:bool State.t -> ?on_click:(unit -> unit) -> string State.t -> node

(** [check_box ?checked ?on_toggled label] creates a check box with optional two-way reactive state binding. *)
val check_box : ?checked:bool State.t -> ?on_toggled:(bool -> unit) -> string -> node

(** [radio_button ?checked ?on_toggled label] creates a radio button with optional reactive state binding. *)
val radio_button : ?checked:bool State.t -> ?on_toggled:(bool -> unit) -> string -> node

(** [line_edit ?placeholder ?text ?on_change ()] creates a single-line text input with two-way state binding. *)
val line_edit : ?placeholder:string -> ?text:string State.t -> ?on_change:(string -> unit) -> unit -> node

(** [text_edit ?read_only ?style ?text ?on_change ()] creates a multi-line text edit. *)
val text_edit : ?read_only:bool -> ?style:string -> ?text:string State.t -> ?on_change:(string -> unit) -> unit -> node

(** [slider ?min ?max ?orientation ?value ?on_change ()] creates a numeric slider with two-way state binding. *)
val slider : ?min:int -> ?max:int -> ?orientation:Widgets.orientation -> ?value:int State.t -> ?on_change:(int -> unit) -> unit -> node

(** [spin_box ?min ?max ?prefix ?suffix ?value ?on_change ()] creates a spin box with two-way state binding. *)
val spin_box : ?min:int -> ?max:int -> ?prefix:string -> ?suffix:string -> ?value:int State.t -> ?on_change:(int -> unit) -> unit -> node

(** [progress_bar ?min ?max ?value ?format ()] creates a progress bar bound to a reactive value. *)
val progress_bar : ?min:int -> ?max:int -> ?value:int State.t -> ?format:string -> unit -> node

(** [combo_box ~items ?current ?on_change ()] creates a drop-down selection box. *)
val combo_box : items:string list -> ?current:int State.t -> ?on_change:(int -> unit) -> unit -> node

(** [canvas ?width ?height ~on_paint ...] creates an interactive 2D graphics canvas. *)
val canvas : ?width:int -> ?height:int -> on_paint:(Gui.Painter.t -> unit) -> ?on_mouse_move:(Widgets.mouse_event -> unit) -> ?on_mouse_press:(Widgets.mouse_event -> unit) -> ?on_mouse_release:(Widgets.mouse_event -> unit) -> ?on_key_press:(Widgets.key_event -> unit) -> unit -> node

(** [custom f] embeds an arbitrary imperative widget creation function into the declarative tree. *)
val custom : (parent:Widgets.qwidget Core.t option -> Widgets.qwidget Core.t) -> node

(** {1 Top-Level Window & Application Runner} *)

(** [window ?title ?width ?height ?status_bar child] wraps [child] in a top-level main window. *)
val window : ?title:string -> ?width:int -> ?height:int -> ?status_bar:string State.t -> node -> node

(** [mount ?parent node] instantiates the declarative tree into a live Qt widget hierarchy. *)
val mount : ?parent:Widgets.qwidget Core.t -> node -> Widgets.qwidget Core.t

(** [run ?args ?title ?width ?height node] mounts the UI, shows the window, and runs the application event loop. *)
val run : ?args:string array -> ?title:string -> ?width:int -> ?height:int -> node -> int
