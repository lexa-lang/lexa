{
  description = "A devshell with clang_17";

  # Specifies the inputs for this flake, including nixpkgs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Utilize flake-utils to simplify multi-system support
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Import the nixpkgs with overlays and configuration options as needed
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        # Define the devShell for your project
        devShell = with pkgs; mkShell {
          buildInputs = [
            clang_17
            valgrind
            jemalloc
            gperftools
            boehmgc

            ghostscript
            graphviz
          ];
          shellHook = ''
            zsh
          '';
        };
      });
}
