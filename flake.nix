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

        clang_dev = pkgs.wrapCC ( pkgs.stdenv.mkDerivation rec {
          pname = "llvm-project";
          version = "dev";

          src = builtins.path { path = "/home/congm/src/llvm-project/build"; };
          dontStrip = true;

          installPhase = ''
            mkdir -p $out/bin
            cp bin/clang $out/bin
            cp bin/opt $out/bin
            cp bin/llc $out/bin
            cp -r lib $out/lib
          '';

          passthru.isClang = true;
        });
        
      in {
        packages.koka = pkgs-unstable.haskellPackages.callPackage ./nix/koka.nix { };
        packages.effektOOPSLA23 = pkgs.callPackage ./nix/effektOOPSLA23.nix { mkSbtDerivation = sbt.mkSbtDerivation;};
        packages.clang_18_preserve_none = pkgs.callPackage ./nix/clang18.nix { };
        packages.effekt_0_2_2 = pkgs.callPackage ./nix/effekt_0_2_2.nix { mkSbtDerivation = sbt.mkSbtDerivation;};
        devShell = with pkgs; mkShell {
          nativeBuildInputs = [
            # clang_main
            # clang_dev
            self.packages.${system}.clang_18_preserve_none
          ];
          buildInputs = [
            mlton
            chez
            nodejs_21
            self.packages.${system}.effektOOPSLA23
            self.packages.${system}.effekt_0_2_2
            self.packages.${system}.koka

            (python3.withPackages (ps: with ps; [
              matplotlib
              numpy

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
            boehmgc

            ghostscript
            graphviz
          ] ++ 
          (with ocaml-ng.ocamlPackages_5_1; [
              ocaml
              dune_3
              utop
              menhir
          ]);
          shellHook = ''
            exec zsh
          '';
        };
      });
}
