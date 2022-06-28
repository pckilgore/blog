let root =
  Dream.router
    [ Dream.get "/health/check" (fun _ -> Dream.json {|{ "healthy": true }|})
    ; Dream.scope "/api" Api.middleware Api.root
    ; Dream.scope "/static" Assets.middleware Assets.router
    ; Dream.get "/" (Dream.from_filesystem "public" "index.html")
    ]
;;
