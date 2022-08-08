let root =
  Dream.router
    [ Dream.get "/health/check" (fun _ -> Dream.json {|{ "healthy": true }|})
    ; Dream.scope "/api" Api.middleware Api.root
    ; Dream.scope "/static" Assets.middleware Assets.router
    ; Dream.scope "/post" Post.middleware Post.router
    ; (Dream.get "/"
      @@ fun _ ->
      Dream.html
        (Template.wrapper ~title:"Patrick Kilgore" ~html:(Template.home ~recents:"")))
    ]
;;
