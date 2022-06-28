(** Re-read the environment *)
val recalculate : unit -> unit

(** Efficiently retreive environment variables *)
val get : string -> string option
