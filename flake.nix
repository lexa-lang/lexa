{
  description = "LED Compiler";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = (with pkgs; [] ++ 
            (with ocaml-ng.ocamlPackages_5_1; [
                ocaml
                dune_3
                utop
                menhir
            ]));
          shellHook = ''
            exec zsh
          '';
        };
      }
    );
}
