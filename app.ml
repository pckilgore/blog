open Core

module Configurable = struct
  let env = Util.Environment.(make () |> env)

  let logger =
    match env with
    | `Prod -> Dream.no_middleware
    | `Test | `Dev -> Dream.logger
  ;;

  let db =
    let open Util in
    match env with
    | `Prod -> Db.connection ()
    | `Test | `Dev -> Db.connection ~db_name:":memory:" ()
  ;;
end

module Init = struct
  let () =
    let db = Configurable.db in
    match Configurable.env with
    | `Test | `Dev ->
      Model.Post.DB.(
        init |> List.iter ~f:(Util.Db.exec_exn ~db);
        seed |> Array.iter ~f:(create ~db))
    | `Prod -> Model.Post.DB.init |> List.iter ~f:(Util.Db.exec_exn ~db)
  ;;
end

let () =
  Dream.run ~interface:"0.0.0.0"
  @@ Configurable.logger
  @@ Middleware.Database.provider ~db:Configurable.db
  @@ Routes.Router.root
;;
