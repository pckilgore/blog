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
end

type headers =
  | CacheControl of CacheControl.t
  | ETag

val to_string : headers -> string
