(** Core Qt 6 types, QObject and runtime utilities *)

type (+'a) t

(** {1 Internal} *)

(** Escape hatches used by the rest of the library. Not part of the supported
    surface, and unsound: [cast] reinterprets a handle's phantom tag without any
    check, so casting between unrelated Qt types produces a handle the runtime
    cannot validate.

    It lives here rather than at the top level because the phantom-variant
    hierarchy (see {!Widgets}) is only meaningful if there is no ordinary way to
    forge a tag. Reach for {!Widget.as_widget} first, which performs a
    statically checked coercion. *)
module Internal : sig
  val cast : 'a t -> 'b t
end

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
