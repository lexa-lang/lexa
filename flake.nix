{
  description = "";

  nixConfig = {
    extra-substituters = [
      "https://lexa-lang.cachix.org"
    ];
    extra-trusted-public-keys = [
      "lexa-lang.cachix.org-1:+sLINOQTFyHLCppbo41mXzTeUpLl/7UR/uvCObyuSt0="
    ];
  };

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
        packages.koka_latest = pkgs-unstable.haskellPackages.callPackage ./nix/koka_latest.nix { 
          lsp_2_4_0_0 = pkgs-unstable.haskellPackages.lsp;
        };
        packages.clang_18_preserve_none = pkgs.callPackage ./nix/clang18.nix { };
        packages.effect_latest = pkgs.callPackage ./nix/effekt_latest.nix { mkSbtDerivation = sbt.mkSbtDerivation;};
        packages.bdwgc = pkgs.callPackage ./nix/bdwgc.nix { };
        packages.libmprompt = pkgs.callPackage ./nix/libmprompt.nix { bdwgc = self.packages.${system}.bdwgc; };
        packages.jetbrains-mono = pkgs.callPackage ./nix/jetbrains-mono.nix { };
        packages.science = pkgs.callPackage ./nix/SciencePlots.nix { };
        packages.lexac = pkgs.callPackage ./nix/lexac.nix { 
          inherit (pkgs.ocaml-ng.ocamlPackages_5_1) buildDunePackage dune_3 menhir ppx_inline_test;
        };
        
        devShells = {
          default = with pkgs; mkShell {
          shellHook = ''
            export PATH=$PWD:$PATH
            export LEXA_MODE=dev
          '';
          FONTCONFIG_FILE = makeFontsConf { 
            fontDirectories = [ self.packages.${system}.jetbrains-mono libertine ];
          };
          nativeBuildInputs = [
            self.packages.${system}.clang_18_preserve_none
          ];
          buildInputs = [
            util-linux
            texliveSmall
            self.packages.${system}.science

            gnumake
            gdb
            vim
            emacs

            mlton
            chez
            nodejs-slim_21
            libuv
            racket
            self.packages.${system}.effect_latest
            self.packages.${system}.koka_latest

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

              pyelftools
              ipykernel
              pip
            ]))
            
            cmake
            ninja
            hyperfine
            
            valgrind
            jemalloc
            gperftools
            self.packages.${system}.bdwgc
            self.packages.${system}.libmprompt

            ghostscript
            graphviz

            llvmPackages.bintools
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

          # User shell with minimal tools, for external Lexa users
          userShell = with pkgs; mkShell {
            shellHook = ''
              export PATH=$PWD:$PATH
              export LEXA_MODE=user
            '';
            nativeBuildInputs = [
              self.packages.${system}.clang_18_preserve_none
            ];
            buildInputs = [
              util-linux
              vim

              (python3.withPackages (ps: with ps; [
                psutil
                numpy
                pandas
                pyelftools
                pip
                capstone
              ]))
              
              hyperfine
              self.packages.${system}.bdwgc
              self.packages.${system}.libmprompt
              self.packages.${system}.lexac
            ]  ++ 
          (with ocaml-ng.ocamlPackages_5_1; [
              opam
              ocaml
              dune_3
              utop
              menhir
              ppx_inline_test
            ]);
          };
        };
      });
}
