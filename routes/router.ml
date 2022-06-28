let main _ = Dream.html "Dream compose"
let health _ = Dream.json {|{ "healthy": true }|}

let root =
  Dream.router
    [ Dream.get "/" main
    ; Dream.get "/health/check" health
    ; Dream.scope "/api" [] Api.root
    ]
;;
