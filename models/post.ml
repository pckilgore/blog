(** 

{0 Posts } are written in Markdown in the posts/ folder. Drafts are stored in
the posts/drafts folder

Their contents are hashed and rendered to html, and cached in sqlite, along with
metadata. 

*)
open Core

module Status = struct
  type t =
    | Draft
    | Published

  let serialize = function
    | Draft -> "Draft"
    | Published -> "Published"
  ;;

  let deserialize = function
    | "Published" -> Published
    | "Draft" | _ -> Draft
  ;;

  let yojson_of_t t = `String (serialize t)

  let t_of_yojson json =
    match json with
    | `String m -> deserialize m
    | _ -> failwith Util.Errors.(to_string (EBadUserInput "post.status"))
  ;;
end

type t =
  { uuid : Uuid.t (** Uniquely identify a post *)
  ; created : Datetime.t (** first time a post with this slug was seen *)
  ; last_published : Datetime.t option (**  *)
  ; slug : string (** the file name of the post, url-friendly *)
  ; status : Status.t
        (** SHA256 Hash of last-rendered contents, used to determine when to rerender *)
  ; hash : Util.Hash.t (** hash of {i markdown} used to generate post *)
  ; html : string option (** Rendered HTML of post *)
  ; title : string
  }
[@@deriving yojson]

module Slug = struct
  let unsafe_chars = Str.regexp_string {|([^\w\d]|_)+|}
  let encode s = Str.global_replace unsafe_chars s "-"
end

module AsFiles = struct
  module Path : sig
    type t

    val to_string : t -> string
    val make : string -> t
  end = struct
    type t = string

    let make t = t
    let to_string t = t
  end

  type t =
    { path : Path.t
    ; slug : string
    ; hash : Util.Hash.t
    ; status : Status.t
    }

  let posts_dir = "./posts"
  let drafts_dir = "./posts/drafts"

  let scan file ~status =
    let path = file |> Filename.concat posts_dir |> Path.make in
    let slug = file |> Filename.chop_extension |> Slug.encode in
    let hash =
      match file |> Util.Hash.of_filename with
      | Some hash -> hash
      | None -> failwith Util.Errors.(to_string (EInternalFileSystem "file went missing"))
    in
    { path; slug; hash; status }
  ;;

  let list_filenames status =
    let dir =
      match status with
      | Status.Draft -> posts_dir
      | Published -> drafts_dir
    in
    Sys_unix.ls_dir dir
    |> List.filter ~f:(fun file ->
           String.(file = "drafts" || Filename.chop_extension file <> ".md"))
    |> List.map ~f:(scan ~status)
  ;;

  let parse_contents_to_html t =
    t.path
    |> Path.to_string
    |> Stdio.In_channel.with_file ~f:Stdio.In_channel.input_all
    |> Omd.of_string
    |> Omd.to_html
  ;;
end

module DB = struct
  let init =
    [ {|CREATE TABLE IF NOT EXISTS posts (
           uuid           TEXT PRIMARY KEY,
           title          TEXT NOT NULL,
           slug           TEXT NOT NULL,
           hash           TEXT NOT NULL,
           created        TEXT NOT NULL,
           status         TEXT NOT NULL,
           last_published TEXT,
           html           TEXT
        ) WITHOUT ROWID;
      |}
    ; {|CREATE UNIQUE INDEX IF NOT EXISTS idx_hash ON posts ("hash");|}
    ; {|CREATE UNIQUE INDEX IF NOT EXISTS idx_slug ON posts ("slug");|}
    ]
  ;;

  let create_stmt = ref None

  let create ~db t =
    let stmt =
      Sqlite3.prepare_or_reset
        db
        create_stmt
        {|INSERT INTO "posts" (
          "uuid",
          "created",
          "last_published",
          "slug",
          "status",
          "hash",
          "html",
          "title"
          ) VALUES (?,?,?,?,?,?,?,?);|}
    in
    let data =
      Sqlite3.Data.
        [ TEXT (t.uuid |> Uuid.to_string)
        ; TEXT (t.created |> Datetime.to_iso)
        ; opt_text (t.last_published |> Option.map ~f:Datetime.to_iso)
        ; TEXT t.slug
        ; TEXT (t.status |> Status.serialize)
        ; TEXT (t.hash |> Util.Hash.serialize)
        ; opt_text t.html
        ; TEXT t.title
        ]
    in
    Sqlite3.bind_values stmt data |> Sqlite3.Rc.check;
    Sqlite3.step stmt |> Sqlite3.Rc.check
  ;;

  let seed =
    [| { uuid = Uuid.make ()
       ; created = Datetime.now ()
       ; last_published = None
       ; slug = "seed-slug"
       ; status = Published
       ; hash = Util.Hash.of_string ""
       ; html = None
       ; title = "Seed Post"
       }
     ; { uuid = Uuid.make ()
       ; created = Datetime.now ()
       ; last_published = None
       ; slug = "seed-slug-2"
       ; status = Published
       ; hash = Util.Hash.of_string "abc"
       ; html = None
       ; title = "Seed Post Two"
       }
    |]
  ;;

  let by_hash_stmt = ref None

  let get_by_hash ~db hash =
    let stmt =
      Sqlite3.prepare_or_reset
        db
        by_hash_stmt
        {|SELECT 
          "uuid",
          "created",
          "last_published",
          "slug",
          "status",
          "hash",
          "html",
          "title"
        FROM posts
        WHERE hash = ?;
    |}
    in
    Sqlite3.bind stmt 1 (TEXT hash) |> Sqlite3.Rc.check;
    Sqlite3.step stmt |> ignore;
    match Sqlite3.row_data stmt with
    | [| uuid; created; last_published; slug; status; hash; html; title |] ->
      Some
        Sqlite3.Data.
          { uuid = uuid |> to_string_exn |> Uuid.deserialize
          ; created = created |> to_string_exn |> Datetime.deserialize
          ; last_published =
              last_published |> to_string |> Option.map ~f:Datetime.deserialize
          ; slug = slug |> to_string_exn
          ; status = status |> to_string_exn |> Status.deserialize
          ; hash = hash |> to_string_exn |> Util.Hash.deserialize
          ; html = html |> to_string
          ; title = title |> to_string_exn
          }
    | [||] | _ -> None
  ;;

  let by_slug_stmt = ref None

  let get_by_slug ~db slug =
    let stmt =
      Sqlite3.prepare_or_reset
        db
        by_slug_stmt
        {|SELECT 
          "uuid",
          "created",
          "last_published",
          "slug",
          "status",
          "hash",
          "html",
          "title"
        FROM posts
        WHERE slug = :slug
        LIMIT 1;
    |}
    in
    Sqlite3.bind_name stmt ":slug" (TEXT slug) |> Sqlite3.Rc.check;
    Sqlite3.step stmt |> ignore;
    match Sqlite3.row_data stmt with
    | [| uuid; created; last_published; slug; status; hash; html; title |] ->
      Some
        Sqlite3.Data.
          { uuid = uuid |> to_string_exn |> Uuid.deserialize
          ; created = created |> to_string_exn |> Datetime.deserialize
          ; last_published =
              last_published |> to_string |> Option.map ~f:Datetime.deserialize
          ; slug = slug |> to_string_exn
          ; status = status |> to_string_exn |> Status.deserialize
          ; hash = hash |> to_string_exn |> Util.Hash.deserialize
          ; html = html |> to_string
          ; title = title |> to_string_exn
          }
    | [||] | _ -> None
  ;;

  let update _t = () (* Update Sqlite *)
end

let init () =
  let posts = AsFiles.list_filenames Published in
  let drafts = AsFiles.list_filenames Draft in
  let all = [ posts; drafts ] in
  List.concat all
  |> List.iter ~f:(fun (_file : AsFiles.t) ->
         (* 
      let post = DB.get_by_hash file.hash in
      if Util.Hash.(post.hash = file.hash) && post.status == file.status
      then
      ()
      else 
      WRITE DIFF TO DB
    *)
         ())
;;
