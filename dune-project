(lang dune 3.10)

(name lexa)

(source
 (github lexa-lang/lexa))

(license MIT)

(package
 (name lexa)
 (description "The Lexa programming language")
 (depends 
  ocaml
  dune 
  ppx_inline_test)
 (allow_empty)
 )

(using menhir 2.1)
(map_workspace_root false)

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
