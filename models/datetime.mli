(** 
Opaque ISO8601 string (millisecond precision) in UTC

Arguably, we'll do a lot of unnecessary alloc/parsing if we really want to
manuipulate these a lot, but I don't really plan on that.  Mostly, this is here
for type safety and easy casting in and out of the db.
**)
type t [@@deriving yojson]

(** Create a new datetime as of time this fn called. **)
val now : unit -> t

(** Print datetime as ISO8601 **)
val to_iso : t -> string

val deserialize : string -> t
