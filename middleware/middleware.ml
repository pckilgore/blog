open Core

module Database = struct
  let db_field : Sqlite3.db Dream.field = Dream.new_field ~name:"database conn" ()

  let provider ~db inner_handler request =
    Dream.set_field request db_field db;
    inner_handler request
  ;;

  let use request =
    match Dream.field request db_field with
    | Some db -> db
    | None ->
      failwith Util.Errors.(to_string (EHandler "Forgot to initialize middleware"))
  ;;
end
