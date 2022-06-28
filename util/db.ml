open Core
open Sqlite3

let default_db_name = "./db.sqlite"
let connection = ref None

(* Open a new db connection or returns existing connection *)
let connection ?(db_name = default_db_name) () =
  match !connection with
  | Some existing_connection -> existing_connection
  | None ->
    let new_connection = db_open db_name in
    exec new_connection "PRAGMA foreign_keys = ON;" |> Rc.check;
    connection := Some new_connection;
    new_connection
;;

(* Spray and pray *)
let exec_exn ~db x = x |> Sqlite3.exec db |> Sqlite3.Rc.check

let ref_print =
  Printf.sprintf ",\nFOREIGN KEY(%s) REFERENCES %s(%s) DEFERRABLE INITIALLY DEFERRED"
;;
