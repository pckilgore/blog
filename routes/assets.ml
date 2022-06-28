let middleware : Dream.middleware list =
  [ Middleware.Response.set_headers ~headers:[ "Cache-Control", "public,max-age=600" ] ]
;;

let router =
  [ Dream.get "/css/**" @@ Dream.static "public/css"
  ; Dream.get "/js/**" @@ Dream.static "public/js"
  ; Dream.get "/img/**" @@ Dream.static "public/img"
  ; Dream.get "/font/**" @@ Dream.static "public/font"
  ; Dream.get "/**" @@ Dream.not_found
  ]
;;
