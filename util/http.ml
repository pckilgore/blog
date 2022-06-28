let key_val_of s1 s2 = Printf.sprintf "%s=%s" s1 s2

module CacheControl : sig
  module Request : sig
    type t = MaxAge

    val to_string : t -> string
  end

  module Response : sig
    type t = NoStore

    val to_string : t -> string
  end

  type t =
    | Response of Response.t list
    | Request of Request.t list

  val to_string : t -> string
end = struct
  module Response = struct
    type t = NoStore

    let to_string = function
      | NoStore -> "no-store"
    ;;
  end

  module Request = struct
    type t = MaxAge

    let to_string = function
      | MaxAge -> "max-age"
    ;;
  end

  let key = "Cache-Control"

  type t =
    | Response of Response.t list
    | Request of Request.t list

  let condense ~f l = l |> List.map f |> String.concat ","

  let to_string = function
    | Request r -> r |> condense ~f:Request.to_string |> key_val_of key
    | Response r -> r |> condense ~f:Response.to_string |> key_val_of key
  ;;
end

type headers =
  | CacheControl of CacheControl.t
  | ETag

let to_string = function
  | CacheControl c -> CacheControl.to_string c
  | ETag -> "ETag"
;;
