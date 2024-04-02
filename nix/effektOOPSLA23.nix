{ pkgs, system, mkSbtDerivation }:

mkSbtDerivation.${system} {
    pname = "effekt";
    version = "OOPSLA23";

    depsSha256 = "sha256-FDUgk98GBchU8ZCYlEUJdL44+SkckfdTCR3TO2EKb/k=";

    src = (pkgs.fetchFromGitHub {
    owner = "effekt-lang";
    repo = "effekt";
    rev = "72f0064f105d79a44e4593c63cfc9bebd84babf9";
    sha256 = "sha256-GNK+vfYx1crhi/Y8nj00ODjfnvmUNKBg9DT8R2xyD3s="; 
    fetchSubmodules = true;
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
}