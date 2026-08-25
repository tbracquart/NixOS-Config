{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./variables.nix
    ./users.nix
    ./boot.nix
    ./audio.nix

    ../../common/system/nix.nix
    ../../common/system/networking.nix
    ../../common/system/locale.nix
    ../../common/system/services.nix
    ../../common/system/security.nix
    ../../common/system/shell.nix
    ../../common/system/programs.nix
    ../../common/system/users.nix
    ../../common/system/packages.nix
    ../../profiles/plasma.nix
  ];

  system.stateVersion = "26.05";
}
