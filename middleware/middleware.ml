open Core

let env = Util.Environment.(make () |> env)

let db =
  match env with
  | `Prod -> Util.Db.connection ()
  | `Test | `Dev -> Util.Db.connection ~db_name:":memory:" ()
;;

let _init : unit =
  match env with
  | `Test | `Dev ->
    Model.Post.DB.(
      init |> List.iter ~f:(Util.Db.exec_exn ~db);
      seed |> Array.iter ~f:(create ~db))
  | `Prod -> Model.Post.DB.init |> List.iter ~f:(Util.Db.exec_exn ~db)
;;

let db_field : Sqlite3.db Dream.field = Dream.new_field ~name:"database conn" ()

let db_middleware inner_handler request =
  Dream.set_field request db_field db;
  inner_handler request
;;

let get_db request =
  match Dream.field request db_field with
  | Some db -> db
  | None -> failwith Util.Errors.(to_string (EHandler "Forgot to initialize middleware"))
;;
