(** Core Qt 6 types, QObject and runtime utilities *)

type (+'a) t

external cast : 'a t -> 'b t = "%identity"

type qobject = [ `QObject ]
type qtimer = [ qobject | `QTimer ]
type qmimedata = [ qobject | `QMimeData ]
type qdrag = [ qobject | `QDrag ]

module Object : sig
  val delete : [> `QObject ] t -> unit
  val is_valid : [> `QObject ] t -> bool
  val set_object_name : [> `QObject ] t -> string -> unit
  val object_name : [> `QObject ] t -> string
  val on_destroyed : [> `QObject ] t -> (unit -> unit) -> unit
end

module Timer : sig
  val single_shot : int -> (unit -> unit) -> unit
  val create : ?parent:[> `QObject ] t -> unit -> qtimer t
  val start : [> `QTimer ] t -> int -> unit
  val stop : [> `QTimer ] t -> unit
  val on_timeout : [> `QTimer ] t -> (unit -> unit) -> unit
end
