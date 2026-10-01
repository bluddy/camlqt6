(lang dune 3.13)
(name camlqt6)
(version 0.1.0)
(generate_opam_files true)
(package
 (name camlqt6)
 (synopsis "Qt 6 bindings for OCaml")
 (description "Cross-platform Qt 6 bindings for OCaml supporting Core, Gui, and Widgets")
 (depends
  (ocaml (>= 5.0.0))
  dune
  dune-configurator))

