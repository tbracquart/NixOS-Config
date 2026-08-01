{
  description = "Flake NixOS pour ZenBook-13";

  inputs = {
    # Ton système sur NixOS 26.05
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # Noctalia avec son propre nixpkgs (unstable)
    noctalia = {
      url = "github:noctalia-dev/noctalia";
    };
  };

  outputs = { self, nixpkgs, noctalia, ... }@inputs: {
    nixosConfigurations = {
      "ZenBook-13" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          noctalia.nixosModules.default  # <-- Correction ici !
          ./hardware-configuration.nix
          ./configuration.nix
        ];
      };
    };
  };
}
