{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./variables.nix
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
    ../../common/system/users.nix
    ../../common/system/packages.nix

    ../../profiles/system/laptop.nix
    ../../profiles/system/plasma.nix
    ../../profiles/system/howdy.nix
  ];

  system.stateVersion = "26.05";
}
