{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./users.nix
    ../../common
    ../../modules
    ../../profiles
    inputs.home-manager.nixosModules.default
    inputs.sops-nix.nixosModules.sops
  ];

  networking.hostName = "V145-15AST";
  system.stateVersion = "26.05";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };

    users.thibaut = {
      imports = [
        ../../users/thibaut/base
      ];
    };

    users.quentin = {
      imports = [
        ../../users/quentin/base.nix
      ];
    };
  };

  my.profile = "laptop";

  my.authentication.howdy.enable = true;
  my.desktop.plasma.enable = true;
  my.flatpak.enable = true;
}
