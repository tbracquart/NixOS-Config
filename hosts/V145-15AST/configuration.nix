{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./users.nix
    ../../common
    ../../profiles/laptop.nix
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

  my.authentication.howdy.enable = true;
  my.desktop.plasma.enable = true;
  my.flatpak.enable = true;
}
