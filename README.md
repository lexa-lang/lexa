Run `nix develop .` to get into the development environment, which include the newest version of clang, necessary to compile promgram in SSTAL.

You need to install nix first.

Running the binary:
```
dune exec -- sstal test/aa.ir -o test/aa.c
```
