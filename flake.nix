{
  description = "A devshell with clang_17";

  # Specifies the inputs for this flake, including nixpkgs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    sbt.url = "github:zaninime/sbt-derivation";
    sbt.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Utilize flake-utils to simplify multi-system support
  outputs = { self, nixpkgs, flake-utils, sbt, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Import the nixpkgs with overlays and configuration options as needed
        pkgs = import nixpkgs {
          inherit system;
        };
        # clang_main = pkgs.wrapCC ( pkgs.stdenv.mkDerivation rec {
        #   pname = "llvm-project";
        #   version = "main";

        #   src = pkgs.fetchFromGitHub {
        #     owner = "llvm";
        #     repo = pname;
        #     rev = "e06f3522cc55cec60084a1278109ab236ef7a3ee";
        #     sha256 = "sha256-AqtIi+G7wL18opmTfZkvOVexkk6YJP+Q5i/zIMKEcr8="; 
        #   };

        #   buildInputs = [ pkgs.python38 ];
        #   nativeBuildInputs = [ pkgs.cmake pkgs.ninja ];
        #   dontUseCmakeConfigure=true;
        #   dontStrip=true;

        #   buildPhase = ''
        #     cmake -S llvm -B build -G Ninja \
        #       -DLLVM_ENABLE_PROJECTS="clang" \
        #       -DCMAKE_BUILD_TYPE=Debug \
        #       -DLLVM_INCLUDE_TESTS=OFF \
        #       -DLLVM_TARGETS_TO_BUILD=X86
        #     ninja -C build clang
        #   '';

        #   installPhase = ''
        #     mkdir -p $out/bin
        #     cp build/bin/clang $out/bin
        #     cp -r build/lib $out/lib
        #   '';

        #   passthru.isClang = true;  
        # });
        clang_18_preserve_none = pkgs.wrapCC ( pkgs.stdenv.mkDerivation rec {
          pname = "llvm-project";
          version = "c166a43";

          src = pkgs.fetchFromGitHub {
            owner = "llvm";
            repo = pname;
            rev = "c166a43c6e6157b1309ea757324cc0a71c078e66";
            sha256 = "sha256-iveg9P2V7WQIQ/eL63vnYBFsR7Ob8a2Vahv8MXm4nyQ="; 
          };

          patchFile = ./preserve_none_no_save_rbp.patch;

          buildInputs = [ pkgs.python38 ];
          nativeBuildInputs = [ pkgs.cmake pkgs.ninja ];
          dontUseCmakeConfigure=true;
          dontStrip=true;

          patchPhase = ''
            patch -p1 -i ${patchFile}
          '';

          buildPhase = ''
            cmake -S llvm -B build -G Ninja \
              -DLLVM_ENABLE_PROJECTS="clang" \
              -DCMAKE_BUILD_TYPE=Release \
              -DLLVM_INCLUDE_TESTS=OFF \
              -DLLVM_TARGETS_TO_BUILD=X86
            ninja -C build
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp build/bin/clang $out/bin
            cp build/bin/opt $out/bin
            cp -r build/lib $out/lib
          '';

          passthru.isClang = true;  
        });
        # kiama = pkgs.stdenv.mkDerivation rec {
        #   name = "kiama";
        #   version = "OOPSLA23";

        #   src = pkgs.fetchFromGitHub {
        #     owner = "effekt-lang";
        #     repo = "kiama";
        #     rev = "89515c8d17c2772d1caba6f1ef7a9ff5d1d93022";
        #     sha256 = "sha256-NJQ3NxzgsOgAaHFItGkeWqOFhjQK0KpMVxLkyHBmJlQ="; 
        #   };
        # };

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
        # packages.effekt = sbt.mkSbtDerivation.${system} {
        #   pname = "effekt";
        #   version = "OOPSLA23";

        #   depsSha256 = "sha256-FDUgk98GBchU8ZCYlEUJdL44+SkckfdTCR3TO2EKb/k=";

        #   src = (pkgs.fetchFromGitHub {
        #     owner = "effekt-lang";
        #     repo = "effekt";
        #     rev = "72f0064f105d79a44e4593c63cfc9bebd84babf9";
        #     sha256 = "sha256-mO1bAOiGCMJxUDEvedfLSlQnwQ+B8WGk1nLAEjvBZW4="; 
        #     fetchSubmodules = true;
        #     leaveDotGit = true;
        #     deepClone = true;
        #   }).overrideAttrs (_: { #https://github.com/NixOS/nixpkgs/issues/195117#issuecomment-1410398050
        #     GIT_CONFIG_COUNT = 1;
        #     GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
        #     GIT_CONFIG_VALUE_0 = "git@github.com:";
        #   });
        #   overrideDepsAttrs = final: prev: {
        #     preBuild = ''
        #       export LANG=C.UTF-8
        #     '';
        #   };

        #   propagatedBuildInputs = with pkgs; [ 
        #     jre
        #   ];
        #   buildInputs = with pkgs; [
        #     nodejs
        #   ];

        #   tmp_file = pkgs.writeText "effekt.sh" ''
        #     #!/usr/bin/env bash
        #     export SCRIPT_DIR=$(dirname $0)
        #     java -jar "$SCRIPT_DIR/effekt" $@
        #   '';
        #   installPhase = ''
        #     export LANG=C.UTF-8
        #     export HOME=$out/home # make npm happy
        #     mkdir -p $out
        #     npm config set prefix $out
        #     sbt install
        #     cp $tmp_file $out/bin/effekt.sh
        #   '';
        # };
        packages.effekt_0_2_2 = sbt.mkSbtDerivation.${system} {
          pname = "effekt";
          version = "v0.2.2";

          depsSha256 = "sha256-PF+t+rbWYt9NOiWVO9B7Ey8/TGtnj9ZTZkiMoWodf6A=";

          src = (pkgs.fetchFromGitHub {
            owner = "effekt-lang";
            repo = "effekt";
            rev = "6f8973ae77e4962b67b3cb626142fab7430a6cd8";
            sha256 = "sha256-6k8cnsJqJM4E4l/bA68Uopm3EZCwGM17XpADtwlJBSQ="; 
            fetchSubmodules = true;
            leaveDotGit = true;
            deepClone = true;
          }).overrideAttrs (_: { #https://github.com/NixOS/nixpkgs/issues/195117#issuecomment-1410398050
            GIT_CONFIG_COUNT = 1;
            GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
            GIT_CONFIG_VALUE_0 = "git@github.com:";
          });
          overrideDepsAttrs = final: prev: {
            preBuild = ''
              export LANG=C.UTF-8
            '';
          };

          propagatedBuildInputs = with pkgs; [ 
            jre
          ];
          buildInputs = with pkgs; [
            nodejs
          ];

          tmp_file = pkgs.writeText "effekt.sh" ''
            #!/usr/bin/env bash
            export SCRIPT_DIR=$(dirname $0)
            java -jar "$SCRIPT_DIR/effekt" $@
          '';
          installPhase = ''
            export LANG=C.UTF-8
            export HOME=$out/home # make npm happy
            mkdir -p $out
            npm config set prefix $out
            sbt install
            cp $tmp_file $out/bin/effekt.sh
          '';
        };
        # Define the devShell for your project
        devShell = with pkgs; mkShell {
          nativeBuildInputs = [
            # clang_main
            # clang_dev
            clang_18_preserve_none
          ];
          buildInputs = [
            mlton
            self.packages.${system}.effekt_0_2_2
            
            cmake
            ninja
            hyperfine
            
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
