{
  description = "NixOS + Home Manager Flake pour ZenBook 13";

  # Configuration automatique des caches binaires (Cachix) pour éviter la compilation
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3FS="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Application FreeSMLauncher
    freesmlauncher = {
      url = "github:FreesmTeam/FreesmLauncher/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

     noctalia-greeter = {
       url = "github:noctalia-dev/noctalia-greeter";
       inputs.nixpkgs.follows = "nixpkgs";
     };
  };

  outputs = { self, nixpkgs, home-manager, freesmlauncher, ... }@inputs: {
    nixosConfigurations.ZenBook-13 = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/ZenBook-13/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.thibaut = import ./hosts/ZenBook-13/home.nix;
        }
      ];
    };

    nixosConfigurations.V145-15AST = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/V145-15AST/configuration.nix
        # Pas de Home Manager ici : machine partagée, pas de config perso à toi dessus.
      ];
    };

    # Config de test pour vérifier la reproductibilité de ZenBook-13 dans une VM vierge
    nixosConfigurations.ZenBook-13-vmtest = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/ZenBook-13-vmtest/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.thibaut = import ./hosts/ZenBook-13-vmtest/home.nix;
        }
      ];
    };
  };
}
