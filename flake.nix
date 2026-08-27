{
  description = "NixOS + Home Manager Flake pour ZenBook 13 et V145-15AST";

  nixConfig = {
    extra-substituters = [
      "https://tbracquart.cachix.org"
      "https://nix-community.cachix.org"
      "https://attic.xuyh0120.win/lantian"
      "https://freesmlauncher.cachix.org"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "tbracquart.cachix.org-1:eTT16nwdreuvu4yagVFB1p+PeRg8ZCZsCA8648IJCZU="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "freesmlauncher.cachix.org-1:Jcp5Q9wiLL+EDv8Mh7c6L9xGk+lXr7/otpKxMOuBuDs="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    freesmlauncher.url = "github:FreesmTeam/FreesmLauncher/develop";

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, freesmlauncher, nix-cachyos-kernel, sops-nix, ... }@inputs:
    let
      commonModules = [
        ./common
        ./modules
        ./profiles
      ];

      hostModules = host: [
        ./hosts/${host}/hardware-configuration.nix
        ./hosts/${host}/boot.nix
        ./hosts/${host}/users.nix
        ./hosts/${host}/configuration.nix
      ];

      hostMetadata = host: stateVersion: {
        networking.hostName = host;
        system.stateVersion = stateVersion;
      };
    in
    {
      nixosConfigurations.ZenBook-13 = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = commonModules
          ++ hostModules "ZenBook-13"
          ++ [
            (hostMetadata "ZenBook-13" "26.05")
            { nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ]; }
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.thibaut = {
                imports = [
                  ./users/thibaut/base
                  ./users/thibaut/variants/zenbook.nix
                ];
              };
            }
          ];
      };

      nixosConfigurations.V145-15AST = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = commonModules
          ++ hostModules "V145-15AST"
          ++ [
            (hostMetadata "V145-15AST" "26.05")
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.thibaut = {
                imports = [
                  ./users/thibaut/base
                ];
              };
              home-manager.users.quentin = {
                imports = [
                  ./users/quentin/base.nix
                ];
              };
            }
          ];
      };
    };
}
