let headers =
  match Util.Environment.get "ENV" with
  | Some "dev" | Some "development" -> []
  | _ -> [ "Cache-Control", "public,max-age=6000,immutable" ]
;;

let middleware : Dream.middleware list = [ Middleware.Response.set_headers ~headers ]

let router =
  [ Dream.get "/css/**" @@ Dream.static "public/css"
  ; Dream.get "/js/**" @@ Dream.static "public/js"
  ; Dream.get "/img/**" @@ Dream.static "public/img"
  ; Dream.get "/font/**" @@ Dream.static "public/font"
  ; Dream.get "/**" @@ Dream.not_found
  ]
;;
