type (+'a) t

module Internal = struct
  (* Unsound tag reinterpretation. Safe only between tags that describe the same
     C++ object hierarchy; never call it with unrelated types. *)
  external cast : 'a t -> 'b t = "%identity"
end

type qobject = [ `QObject ]
type qtimer = [ qobject | `QTimer ]
type qmimedata = [ qobject | `QMimeData ]
type qdrag = [ qobject | `QDrag ]

external qobject_delete : 'a t -> unit = "caml_oqt6_qobject_delete"
external qobject_is_valid : 'a t -> bool = "caml_oqt6_qobject_is_valid"
external qobject_set_object_name : 'a t -> string -> unit = "caml_oqt6_qobject_set_object_name"
external qobject_object_name : 'a t -> string = "caml_oqt6_qobject_object_name"
external qobject_connect_destroyed : 'a t -> (unit -> unit) -> unit = "caml_oqt6_qobject_connect_destroyed"

module Object = struct
  let delete = qobject_delete
  let is_valid = qobject_is_valid
  let set_object_name = qobject_set_object_name
  let object_name = qobject_object_name
  let on_destroyed = qobject_connect_destroyed
end

external qtimer_single_shot : int -> (unit -> unit) -> unit = "caml_oqt6_qtimer_single_shot"
external qtimer_create : 'a t option -> qtimer t = "caml_oqt6_qtimer_create"
external qtimer_start : 'a t -> int -> unit = "caml_oqt6_qtimer_start"
external qtimer_stop : 'a t -> unit = "caml_oqt6_qtimer_stop"
external qtimer_connect_timeout : 'a t -> (unit -> unit) -> unit = "caml_oqt6_qtimer_connect_timeout"

module Timer = struct
  let single_shot = qtimer_single_shot
  let create ?parent () = qtimer_create parent
  let start = qtimer_start
  let stop = qtimer_stop
  let on_timeout = qtimer_connect_timeout
end
