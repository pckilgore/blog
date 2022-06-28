open Util
open Alcotest

let test_hashing () =
  (* Lots of shitty assumptions here. TODO: Cleanup *)
  Sys.chdir "../../..";
  Hash.of_filename
    (Core.Filename.to_absolute_exn
       ~relative_to:(Sys.getcwd ())
       "./tests/fixtures/hash-post.md")
  |> Option.get
  |> Hash.serialize
  |> (check string) "hash is" "ed4054118f08cc25b328fdd980035239"
;;

let () =
  let open Alcotest_lwt in
  Lwt_main.run
  @@ run
       "Utils"
       [ "Util.Hash.of_filename", [ test_case_sync "works" `Quick test_hashing ] ]
;;
