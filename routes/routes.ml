let root _ = Dream.html "Dream compose"
let health _ = Dream.json {|{ "healthy": true }|}

let router =
  Dream.router
    [ Dream.get "/" root
    ; Dream.get "/health/check" health
    ; Dream.get "/1" root
    ; Dream.get "/2" root
    ; Dream.get "/3" root
    ; Dream.get "/4" root
    ; Dream.get "/5" root
    ; Dream.get "/6" root
    ]
;;
