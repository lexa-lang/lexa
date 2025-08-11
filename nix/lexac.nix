{ lib
, buildDunePackage
, dune_3
, menhir
, ppx_inline_test
}:

buildDunePackage rec {
  pname = "lexac";
  version = "dev";

  src = ../.;

  nativeBuildInputs = [
    dune_3
    menhir
  ];

  buildInputs = [
    ppx_inline_test
  ];

  doCheck = false;

  # Override the install phase to install the lexac executable
  installPhase = ''
    mkdir -p $out/bin
    cp _build/default/src/bin/main.exe $out/bin/lexac
  '';

  meta = with lib; {
    description = "The Lexa programming language compiler";
    homepage = "https://github.com/lexa-lang/lexa";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
} 