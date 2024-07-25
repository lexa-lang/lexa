{ pkgs, system, mkSbtDerivation }:

mkSbtDerivation.${system} {
    pname = "effekt";
    version = "07_25_2024";

    depsSha256 = "sha256-PF+t+rbWYt9NOiWVO9B7Ey8/TGtnj9ZTZkiMoWodf6A=";

    src = (pkgs.fetchFromGitHub {
    owner = "effekt-lang";
    repo = "effekt";
    rev = "7b7629c942e2809cab08b0122e244ba3bcbb9410";
    sha256 = "sha256-/VQUsXpkPLGcin2UWgvo2sV8bDopSfAn8dewCBu4pkw="; 
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

    tmp_file = pkgs.writeText "effekt_latest.sh" ''
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
    cp $tmp_file $out/bin/effekt_latest.sh
    chmod +x $out/bin/effekt_latest.sh
    '';
}