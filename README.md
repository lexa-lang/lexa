
## Setup(Assuming you have a local devbox and have access to plg7a)
### On Local Devbox
1. Install VSCode and extentions [Remote - SSH
](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh), [direnv](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv) and [OCaml Platform](https://marketplace.visualstudio.com/items?itemName=ocamllabs.ocaml-platform)
2. Setup VSCode SSH extension with plg7a following [instructions](https://code.visualstudio.com/docs/remote/ssh#_connect-to-a-remote-host)

### On plg7a
1. SSH into plg7a
2. Install `direnv` using `nix-env -iA nixpkgs.direnv` and hook it into your shell following [instructions](https://direnv.net/docs/hook.html)
3. Restart your shell
4. Clone this repo and `cd` into it
5. Enable direnv: `direnv allow .`

### Check if everything is setup correctly
1. Run `dune build` to build the project
2. Open a .ml file and hover over a function or a variable, you should see its type

## Test
We have three kinds of tests, each serving a different purpose. For `Compiler Test` and `Integration Test` we uses Cram Test framework; for `Unit Test` we use ppx_inline_test. Read more in [Writing and Running Tests — Dune documentation](https://dune.readthedocs.io/en/stable/tests.html#)
 1. `Compiler Test` runs Lexi complier on a set of simple programs, and compare the generated C code with a previous recorded version.
2. `Integration Test` runs Lexi compiler followed by Clang, and checks correctness of the produced binary.
3. `Unit Test` checks correctness of individual functions.
### Running Compiler Tests
```
dune runtest ./test/compile
```
### Running integration Tests(Currently fails)
```
dune runtest ./test/integration
```
### Running Unit Tests
```
dune  runtest
```