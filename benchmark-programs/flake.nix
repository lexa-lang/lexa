{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";  # Adjust for your desired channel
    # Or use a specific commit hash 
  };

  outputs = { self, nixpkgs }: 
    let 
      system = "x86_64-linux";  # Adapt if needed
      myPackages = pkgs: with pkgs; [
        clang_17
        jemalloc
      ]; 
    in {
      packages.${system} = myPackages; 

      defaultPackage = myPackages.clang_17;  # Sets Clang 17 as default when using nix develop
    };
}
