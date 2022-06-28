open Core

module Config = struct
  let env = Util.Environment.(make () |> env)

  let logging_middleware =
    match env with
    | `Prod -> Dream.no_middleware
    | `Test | `Dev -> Dream.logger
  ;;
end

let () =
  Dream.run ~interface:"0.0.0.0"
  @@ Config.logging_middleware
  @@ Middleware.db_middleware
  @@ Routes.Router.root
;;
