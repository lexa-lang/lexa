{ pkgs, system, mkSbtDerivation }:

mkSbtDerivation.${system} {
    pname = "effekt";
    version = "v0.2.2";

    depsSha256 = "sha256-PF+t+rbWYt9NOiWVO9B7Ey8/TGtnj9ZTZkiMoWodf6A=";

    src = (pkgs.fetchFromGitHub {
    owner = "effekt-lang";
    repo = "effekt";
    rev = "6f8973ae77e4962b67b3cb626142fab7430a6cd8";
    sha256 = "sha256-1VrzzVxy8Zv4M8g2VKLKELXzofAGdKRKoy8ZQV3nNAw="; 
    fetchSubmodules = true;
    }).overrideAttrs (_: { #https://github.com/NixOS/nixpkgs/issues/195117#issuecomment-1410398050
    GIT_CONFIG_COUNT = 1;
    GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
    GIT_CONFIG_VALUE_0 = "git@github.com:";
    });

    patches = [ ./substitude_char_in_effekt.patch ];
    
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

    tmp_file = pkgs.writeText "effekt022.sh" ''
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
    cp $tmp_file $out/bin/effekt022.sh
    chmod +x $out/bin/effekt022.sh
    '';
}