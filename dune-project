(lang dune 3.13)
(name camlqt6)
(version 0.1.0)
(generate_opam_files true)

(package
 (name camlqt6)
 (synopsis "Qt 6 bindings for OCaml")
 (description
  "Cross-platform Qt 6 bindings for OCaml supporting Core, Gui, and Widgets.\n\nProvides an imperative widget API, a functional QAbstractItemModel bridge for\nQTableView that does not copy the bound data (there is no equivalent tree model\nyet), a QPainter/custom-painting canvas, and a declarative reactive DSL, with\nQPointer-based lifetime tracking and OCaml 5 domain-lock safety.")
 (authors "CamlQt6 contributors")
 (maintainers "CamlQt6 contributors")
 (license MIT)
 (homepage "https://github.com/bluddy/camlqt6")
 (bug_reports "https://github.com/bluddy/camlqt6/issues")
 (depends
  ;; Qt itself is discovered at configure time by config/discover.ml, which
  ;; probes QTDIR / Qt6_DIR / pkg-config / qmake6. There is no maintained conf
  ;; package for Qt 6, so the dependency is declared as conf-pkg-config plus the
  ;; platform depexts in camlqt6.opam.template rather than a `conf-qt6`.
  (ocaml (>= 5.0.0))
  dune-configurator
  ;; conf-pkg-config, not `pkg-config`: discover.ml execs the pkg-config binary,
  ;; and there is no opam package called `pkg-config` (the OCaml binding of that
  ;; name was never in opam-repository, so `opam install camlqt6` failed with
  ;; "Missing dependency: deps-of-camlqt6 -> pkg-config / unknown package").
  ;; opam lint does not check that dependencies resolve, so this passed review.
  conf-pkg-config))