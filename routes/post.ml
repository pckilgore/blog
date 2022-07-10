open Core

let middleware : Dream.middleware list =
  [ Middleware.Response.set_headers ~headers:[ "Cache-Control", "public,max-age=86400" ] ]
;;

let get_post req =
  let db = Middleware.Database.use req in
  let slug = Dream.param req "slug" in
  match Model.Post.DB.get_by_slug ~db slug with
  | Some { html = Some html; title; _ } -> Dream.html (Template.wrapper ~html ~title)
  | Some { html = None; _ } -> Dream.html Template.render_err
  | None ->
    Dream.html
      ~status:`Not_Found
      (Template.wrapper ~title:"Not Found" ~html:Template.not_found)
;;

let router =
  [ (Dream.get "/" @@ fun r -> Dream.redirect r "/"); Dream.get "/:slug" @@ get_post ]
;;
