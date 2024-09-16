{
  pkgs,
  lib,
  fetchFromGitHub
}:

pkgs.python3Packages.buildPythonPackage rec {
  pname = "SciencePlots";
  version = "2.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "garrettj403";
    repo = "SciencePlots";
    rev = "${version}";
    hash = "sha256-48RgSX0q0TcoHzQYtRtMPygFUAoc1X8814DVZrs/Nd4=";
  };

  nativeBuildInputs = with pkgs.python3Packages; [
    setuptools
    setuptools-scm
    matplotlib
  ];

}