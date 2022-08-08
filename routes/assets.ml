let headers =
  match Util.Environment.get "ENV" with
  | Some "dev" | Some "development" -> []
  | _ -> [ "Cache-Control", "public,max-age=6000,immutable" ]
;;

(* middleware *)
let middleware : Dream.middleware list = [ Middleware.Response.set_headers ~headers ]

module Css = struct
  open Re2

  (* Match the hash of `style.<HASH>.css` *)
  let match_hash = create_exn {|^.+style\.([A-Fa-f0-9]+)\.css$|}

  (** Is this file a css file with our cache-buster pattern *)
  let is_pattern request = request |> Dream.target |> matches match_hash

  (** If this route matches our CSS cache buster pattern, return our built CSS
     file, otherwise, 404. *)
  let resolver request =
    if is_pattern request
    then request |> Dream.from_filesystem "." "style.build.css"
    else request |> Dream.not_found
  ;;
end

(* subroutes *)
let router = [ Dream.get "/css/**" @@ Css.resolver; Dream.get "**" @@ Dream.not_found ]
