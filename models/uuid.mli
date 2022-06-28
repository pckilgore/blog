type t [@@deriving yojson]

val make : unit -> t
val to_string : t -> string
val deserialize : string -> t
