(** A dependency violated a constraint **)
exception EVendorFail of string

exception EInternalFileSystem of string
exception EHandler of string
exception EBadUserInput of string

let to_string = function
  | EVendorFail m -> "Apple: " ^ m
  | EInternalFileSystem m -> "Banana: " ^ m
  | EHandler m -> "Carrot: " ^ m
  | EBadUserInput m -> "Durian: " ^ m
  | _ -> "Unicorn"
;;
