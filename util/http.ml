let render_kv_pair s1 s2 = Printf.sprintf "%s=%s" s1 s2

type 'a mode =
  | Request of 'a
  | Response of 'a

module Headers = struct
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
      | Request r -> r |> condense ~f:Request.to_string |> render_kv_pair key
      | Response r -> r |> condense ~f:Response.to_string |> render_kv_pair key
    ;;
  end

  type response_headers =
    | CacheControl of CacheControl.t
    | ETag

  type t =
    | Request of string
    | Response of response_headers

  let response_to_string = function
    | CacheControl c -> CacheControl.to_string c
    | ETag -> "ETag"
  ;;

  let to_string = function
    | Response res -> response_to_string res
    | Request s -> s
  ;;
end
