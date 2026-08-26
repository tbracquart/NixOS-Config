{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./boot.nix

    ../../common/system/nix.nix
    ../../common/system/networking.nix
    ../../common/system/locale.nix
    ../../common/system/keyboard.nix
    ../../common/system/services.nix
    ../../common/system/security.nix
    ../../common/system/shell.nix
    ../../common/system/programs.nix
    ../../common/users/thibaut.nix
    ../../common/system/packages.nix

    ../../modules/authentication
    ../../modules/desktop
    ../../profiles/laptop.nix
  ];

  networking.hostName = "V145-15AST";

  my.authentication.howdy.enable = true;
  my.desktop.plasma.enable = true;

  system.stateVersion = "26.05";
}
