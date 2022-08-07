(lang dune 3.3)

(name blog)

(version 1.0.0)

(generate_opam_files true)

(source
 (github pckilgore/blog))

(authors "Patrick Kilgore")

(maintainers "Patrick Kilgore")

(license ISC)

(package
 (name blog)
 (synopsis "My Blog")
 (depends
  (alcotest :with-test)
  (alcotest-lwt :with-test)
  (core
   (>= 0.15.0))
  (core_unix
   (>= 0.14.0))
  (stdio
   (>= 0.15.0))
  (dream
   (= 1.0.0~alpha4))
  (sqlite3
   (= 5.1.0))
  (nanoid
   (>= 1.0.0))
  (timedesc
   (= 0.6.0))
  (omd
   (= 1.3.1))
  (ppx_yojson_conv
    (>= 0.15.0))
  (dune
   (>= 3.3))))
