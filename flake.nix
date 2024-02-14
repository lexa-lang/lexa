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
        clang_main = pkgs.wrapCC ( pkgs.stdenv.mkDerivation rec {
          pname = "llvm-project";
          version = "main";

          src = pkgs.fetchFromGitHub {
            owner = "llvm";
            repo = pname;
            rev = "e06f3522cc55cec60084a1278109ab236ef7a3ee";
            sha256 = "sha256-AqtIi+G7wL18opmTfZkvOVexkk6YJP+Q5i/zIMKEcr8="; 
          };

          buildInputs = [ pkgs.python38 ];
          nativeBuildInputs = [ pkgs.cmake pkgs.ninja ];
          dontUseCmakeConfigure=true;

          buildPhase = ''
            cmake -S llvm -B build -G Ninja \
              -DLLVM_ENABLE_PROJECTS="clang" \
              -DCMAKE_BUILD_TYPE=Release \
              -DLLVM_INCLUDE_TESTS=OFF \
              -DLLVM_TARGETS_TO_BUILD=X86
            ninja -C build clang
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp build/bin/clang $out/bin
            cp -r build/lib $out/lib
          '';

          passthru.isClang = true;  
        });
      in {
        # Define the devShell for your project
        devShell = with pkgs; mkShell {
          nativeBuildInputs = [
            clang_main
          ];
          buildInputs = [
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
