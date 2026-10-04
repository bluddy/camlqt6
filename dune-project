(lang dune 3.13)
(name camlqt6)
(version 0.1.0)
(generate_opam_files true)

(package
 (name camlqt6)
 (synopsis "Qt 6 bindings for OCaml")
 (description
  "Cross-platform Qt 6 bindings for OCaml supporting Core, Gui, and Widgets.\n\nProvides an imperative widget API, a zero-copy functional QAbstractItemModel\nbridge, a QPainter/custom-painting canvas, and a declarative reactive DSL, with\nQPointer-based lifetime tracking and OCaml 5 domain-lock safety.")
 (authors "CamlQt6 contributors")
 (maintainers "CamlQt6 contributors")
 (license MIT)
 (homepage "https://github.com/camlqt6/camlqt6")
 (bug_reports "https://github.com/camlqt6/camlqt6/issues")
 (depends
  ;; Qt itself is discovered at configure time by config/discover.ml, which
  ;; probes QTDIR / Qt6_DIR / pkg-config / qmake6. There is no maintained conf
  ;; package for Qt 6, so the dependency is declared as pkg-config plus the
  ;; platform depexts in camlqt6.opam.template rather than a `conf-qt6`.
  (ocaml (>= 5.0.0))
  dune-configurator
  pkg-config))