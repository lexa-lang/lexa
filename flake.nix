{
  description = "";

  # Specifies the inputs for this flake, including nixpkgs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    sbt.url = "github:zaninime/sbt-derivation";
    sbt.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Utilize flake-utils to simplify multi-system support
  outputs = { self, nixpkgs, unstable, flake-utils, sbt, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Import the nixpkgs with overlays and configuration options as needed
        pkgs = import nixpkgs {
          inherit system;
        };
        pkgs-unstable = import unstable {
          inherit system;
        };

        
      in {
        packages.koka_3_1_1 = pkgs-unstable.haskellPackages.callPackage ./nix/koka.nix { };
        packages.clang_18_preserve_none = pkgs.callPackage ./nix/clang18.nix { };
        packages.effect_latest = pkgs.callPackage ./nix/effekt_latest.nix { mkSbtDerivation = sbt.mkSbtDerivation;};
        packages.bdwgc = pkgs.callPackage ./nix/bdwgc.nix { };
        packages.jetbrains-mono = pkgs.callPackage ./nix/jetbrains-mono.nix { };
        devShell = with pkgs; mkShell {
          FONTCONFIG_FILE = makeFontsConf { 
            fontDirectories = [ self.packages.${system}.jetbrains-mono libertine ];
          };
          nativeBuildInputs = [
            self.packages.${system}.clang_18_preserve_none
          ];
          buildInputs = [
            texliveSmall

            gnumake
            gdb
            vim
            emacs

            mlton
            chez
            nodejs-slim_21
            racket
            self.packages.${system}.effect_latest
            self.packages.${system}.koka_3_1_1

            (python3.withPackages (ps: with ps; [
              psutil
              matplotlib
              numpy
              pandas

              capstone
              keystone-engine
              pygments
              requests
              ropper
              rpyc
              unicorn
            ]))
            
            cmake
            ninja
            hyperfine
            
            valgrind
            jemalloc
            gperftools
            self.packages.${system}.bdwgc

            ghostscript
            graphviz
          ] ++ 
          (with ocaml-ng.ocamlPackages_5_1; [
              ocaml-lsp
              opam
              ocaml
              dune_3
              utop
              menhir
              ppx_inline_test
              earlybird
          ]);
        };
      });
}
