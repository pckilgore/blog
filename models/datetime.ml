module T = Timedesc

type t = string [@@deriving yojson]

let now () =
  match T.now ~tz_of_date_time:Timedesc.Time_zone.utc () |> T.to_iso8601_milli with
  | Some t -> t
  | None -> failwith Util.Errors.(to_string (EVendorFail "Timedesc"))
;;

let to_iso t = t
let deserialize t = t
