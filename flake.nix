{
  description = "NixOS + Home Manager Flake pour ZenBook 13";

  # Configuration automatique des caches binaires (Cachix) pour éviter la compilation
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://attic.xuyh0120.win/lantian"
      "https://freesmlauncher.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "freesmlauncher.cachix.org-1:Jcp5Q9wiLL+EDv8Mh7c6L9xGk+lXr7/otpKxMOuBuDs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Application FreeSMLauncher (épinglé sur une release taguée pour matcher leur cache Cachix ;
    # se met à jour normalement via `nix flake update`, comme les autres inputs)
    freesmlauncher = {
      url = "github:FreesmTeam/FreesmLauncher/2.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

     noctalia-greeter = {
       url = "github:noctalia-dev/noctalia-greeter";
       inputs.nixpkgs.follows = "nixpkgs";
     };

    # Kernel CachyOS + BORE, précompilé (Chaotic-Nyx est archivé, ce fork le remplace)
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Extensions Firefox packagées pour Nix (fournit l'extension Pywalfox)
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, freesmlauncher, nix-cachyos-kernel, ... }@inputs: {
    nixosConfigurations.ZenBook-13 = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ]; }
        ./hosts/ZenBook-13/hardware-configuration.nix
        ./common/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.thibaut = import ./common/home.nix;
        }
      ];
    };

    nixosConfigurations.V145-15AST = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/V145-15AST/configuration.nix
      ];
    };
  };
}

