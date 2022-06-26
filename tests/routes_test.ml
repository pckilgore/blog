let test_client = Dream.test Routes.router

(** Common alcotest assertions over Dream **)
module Assert = struct
  open Dream
  open Alcotest

  (** Assert request.status **)
  let status want resp =
    resp |> status |> status_to_int |> (check int) "status eq" (status_to_int want)
  ;;

  (** Assert request.body **)
  let body want resp = resp |> body |> Lwt.map ((check string) "status eq" want)
end

module Root = struct
  let res = Dream.request ~method_:`GET ~target:"/" "" |> test_client
  let status () = res |> Assert.status `OK
  let body _ () = res |> Assert.body "Dream compose"
end

let () =
  let open Alcotest_lwt in
  Lwt_main.run
  @@ run
       "Routes tests"
       [ ( "root"
         , [ test_case_sync "status" `Quick Root.status
           ; test_case "body" `Quick Root.body
           ] )
       ]
;;
