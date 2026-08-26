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

    ../../modules/desktop/plasma.nix
    ../../modules/authentication/howdy.nix
    ../../profiles/laptop.nix
  ];

  networking.hostName = "V145-15AST";

  system.stateVersion = "26.05";
}
