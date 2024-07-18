(lang dune 3.10)

(name sstal)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name sstal)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends 
  ocaml
  dune 
  ppx_inline_test
  menhir)
 (allow_empty)
 (tags
  (topics "to describe" your project)))

(using menhir 2.1)
(map_workspace_root false)

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
