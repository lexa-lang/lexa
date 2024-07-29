
## Setup(Assuming you have a local devbox and have access to plg2.cs.uwaterloo.ca)
### On Local Devbox
1. Install VSCode and extention [Remote - SSH
](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)
2. Setup VSCode SSH extension with plg2 following [instructions](https://code.visualstudio.com/docs/remote/ssh#_connect-to-a-remote-host)
3. Connect to plg2
4. Install additional extensions on plg2: [direnv](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv) and [OCaml Platform](https://marketplace.visualstudio.com/items?itemName=ocamllabs.ocaml-platform)

### On plg2
1. SSH into plg2
2. Clone this repo
3. Move the custom nix binary at `./dev/bin/nix` into PATH
4. Run `mkdir -p ~/.config/nix; echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf`
5. Re-enter the shell, run `nix run nixpkgs#hello` and make sure there's no error
6. Install `direnv`: `nix profile install nixpkgs#direnv`
7. Hook up `direnv` with your shell following [instructions](https://direnv.net/docs/hook.html)
8. Re-enter the shell

### Check if everything is setup correctly
1. Run `dune build` to build the project
2. Open a .ml file and hover over a function or a variable, you should see its type

## Debug
The repository is setup with Ocamlearlybird, a debugger for OCaml with nice integration with VSCode. To debug, follow these steps:
1. Open a .ml file
2. Set a breakpoint by clicking on the left margin of the editor
3. Press `F5`(or `Cmd + Shift + D` and click green button) to start debugging
4. You can now step through the code using the debug toolbar

## Test
We have three kinds of tests, each serving a different purpose. For `Compiler Test` and `Integration Test` we uses Cram Test framework; for `Unit Test` we use ppx_inline_test. Read more in [Writing and Running Tests — Dune documentation](https://dune.readthedocs.io/en/stable/tests.html#)
1. `Compiler Test` runs Lexi complier on a set of simple programs, and compare the generated C code with a previous recorded version. This suite of tests are expected to fail if you are making changes to the code generation logic; when it happens, run `dune promote` to update the tests.
2. `Integration Test` runs Lexi compiler followed by Clang, and checks correctness of the produced binary.
3. `Unit Test` checks correctness of individual OCaml functions.
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