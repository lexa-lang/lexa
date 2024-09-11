{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "jetbrains-mono";
  version = "2.304";

  src = fetchurl {
    url = "https://github.com/JetBrains/JetBrainsMono/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-2Nq1/yT8njRdbHmH8nRs+N9PhwVh6onBRjC40XKf1yc=";
  };
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  doCheck = false;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/fonts/opentype/ fonts/otf/*.otf
    runHook postInstall
  '';

  meta = with lib; {
    description = "A typeface made for developers";
    homepage = "https://jetbrains.com/mono/";
    changelog = "https://github.com/JetBrains/JetBrainsMono/blob/v${version}/Changelog.md";
    license = licenses.ofl;
    maintainers = with maintainers; [ vinnymeller ];
    platforms = platforms.all;
  };
}