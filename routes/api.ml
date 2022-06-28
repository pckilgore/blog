let api_404 _ = Dream.json ~code:404 {|{ "message": "Not found" }|}
let middleware = []

module PostResource = struct
  let get_by_hash request =
    let db = Middleware.Database.use request in
    let hash = Dream.param request "hash" in
    match hash |> Model.Post.DB.get_by_hash ~db with
    | Some t -> t |> Model.Post.yojson_of_t |> Yojson.Safe.to_string |> Dream.json
    | None -> api_404 ()
  ;;

  let router = [ Dream.get "/hash/:hash" @@ get_by_hash ]
end

let stats _ = Dream.json {|[ ]|}

let root =
  [ Dream.get "/stats" stats
  ; Dream.scope "/post" [] PostResource.router
  ; Dream.get "/**" api_404
  ]
;;
