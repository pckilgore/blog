type t [@@deriving yojson]

(* Hash file at path *)
val of_filename : string -> t option
val of_string : string -> t
val compare : t -> t -> int
val deserialize : string -> t
val serialize : t -> string
val ( = ) : t -> t -> bool
