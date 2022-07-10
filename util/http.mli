type 'a mode =
  | Request of 'a
  | Response of 'a

(** 
    Typesafe HTTP Headers *)
module Headers : sig
  (** 
      Typesafe Cache-Control Headers *)
  module CacheControl : sig
    (** 
      Typesafe Cache-Control Headers *)
    module Request : sig
      type t = MaxAge

      val to_string : t -> string
    end

    (** 
      Typesafe Cache-Control Headers *)
    module Response : sig
      type t = NoStore

      val to_string : t -> string
    end

    type t =
      | Response of Response.t list
      | Request of Request.t list

    val to_string : t -> string
  end

  type response_headers =
    | CacheControl of CacheControl.t
    | ETag

  type t =
    | Request of string
    | Response of response_headers

  val to_string : t -> string
end
