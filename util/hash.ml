open Core

type t = string [@@deriving yojson]

let of_filename f =
  let x =
    try
      f |> Stdio.In_channel.read_all |> Md5.digest_string |> Md5.to_hex |> Option.some
    with
    | _ -> None
  in
  x
;;

let of_string s = Md5.digest_string s |> Md5.to_hex
let deserialize t = t
let serialize t = t
let compare = String.compare
let ( = ) = String.( = )
let ( <> ) = String.( <> )
