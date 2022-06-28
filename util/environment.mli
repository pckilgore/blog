type t

(** Read environment vars and write to a map. output is memoized by default **)
val make : ?recalculate:bool -> unit -> t

(**
Retrieve high level execution environment from Environment.t

Set via ENV=production|dev|test
**)
val env : t -> [ `Dev | `Prod | `Test ]
