open Core
module M = Map.Make (String)

type t = string M.t

let make ?(recalculate = false) () =
  let memo = ref None in
  let parse () =
    Core_unix.environment ()
    |> Array.fold_right
         ~f:(fun pair assoc_list ->
           match String.split ~on:'=' pair with
           | [ key; value ] -> (key, value) :: assoc_list
           | _ -> assoc_list)
         ~init:[]
    |> M.of_alist_exn
  in
  match recalculate, !memo with
  | true, Some _ | _, None ->
    let env = parse () in
    memo := Some env;
    env
  | false, Some env -> env
;;

let env t =
  match Map.find t "ENV" with
  | Some "dev" -> `Dev
  | Some "development" -> `Dev
  | Some "test" -> `Test
  | Some _ | None -> `Prod
;;
