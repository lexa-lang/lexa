
## Setup
1. Install `nix` package manager. Note that many nix commands used requires explicit CLI argument `--extra-experimental-features "nix-command flakes"`, but for conciseness we will omit it in this document.
2. Clone the repo
3. Run `nix develop .` to get into the development environment. Running this command for the first time will take around 1 hour on a 4 core machine, as it will build a custom Clang.

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