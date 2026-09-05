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
      "tbracquart.cachix.org-1:7Q5fYQ9g5kq8xYh1xXnqVYQ4lYx0k0x0x0x0x0x0x0="
      "nix-community.cachix.org-1:6m2h5j4l8m8f7f7l3w0f8f5g6q2r3s4t5u6v7w8x9y0="
      "lantian.cachix.org-1:7g3m5p6r8t0v2x4z6b8n0m2q4w6e8r0t2y4u6i8o0p="
      "freesmlauncher.cachix.org-1:4f5r6e7e8s9m0l1a2u3n4c5h6e7r8c9a0c1h2="
      "noctalia.cachix.org-1:5n6o7c8t9a0l1i2a3c4a5c6h7i8x9k0e1y2="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    freesmlauncher.url = "github:FreesmTeam/FreesmLauncher/develop";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, freesmlauncher, nix-cachyos-kernel, sops-nix, ... }@inputs:
    let
      stateVersion = "26.05";

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

      hostMetadata = host: {
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
            (hostMetadata "ZenBook-13")
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
            (hostMetadata "V145-15AST")
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
