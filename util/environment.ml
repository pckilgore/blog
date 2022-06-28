open Core
module M = Map.Make (String)

let parse_env () =
  Core_unix.environment ()
  |> Array.fold_right
       ~f:(fun key_value_pair assoc_list ->
         match String.split ~on:'=' key_value_pair with
         | [ key; value ] -> (key, value) :: assoc_list
         | _ -> assoc_list)
       ~init:[]
  |> M.of_alist_exn
;;

let memo = ref (parse_env ())
let recalculate () = memo := parse_env ()
let get key = M.find !memo key
