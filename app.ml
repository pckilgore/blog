open Core

(** Encapsulate configure for the app. If it's a knob, it's here. Checkout the
    Util.Environment module for specifics, but  *)
module Configurable = struct
  module Env = Util.Environment

  let env =
    match Env.get "ENV" with
    | Some "dev" -> `Dev
    | Some "development" -> `Dev
    | Some "test" -> `Test
    | Some _ | None -> `Prod
  ;;

  let logger = Dream.logger

  let db =
    let open Util in
    match env with
    | `Prod -> Db.connection ()
    | `Test | `Dev -> Db.connection ~db_name:":memory:" ()
  ;;
end

(**
  {0 Init}
  We front-load a lot of work in this application, not really for performance but
  because it was fun to design something this way. In general:

  In general, the process here is the same except that in production we use an
  actual database file instead of an in-memory database (this file actually comes
  from lightline on-instance-start, checkout the Dockerfile), and we manually
  apply migrations vs. blasting the whole schema at the db at once.

   {- Create a DB connection}
   {- Apply schema (Dev/Test only)
   {- Read in all Markdown files, eagerly convert to html and update database with 
     contents + metadata}

  The net result is that we only hit the filesystem for posts once, and all other
  IO is through Sqlite3 for blazing speed. Yes, this is awfully close to a static
  site generator without the static part, but I plan to incrementally upgrade
  functionality to include non-static components. And learning Sqlite3 was fun. 
  Baby steps. *)
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
