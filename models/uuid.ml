type t = string [@@deriving yojson]

let make () = Nanoid.nanoid ()
let deserialize t = t
let to_string t = t
