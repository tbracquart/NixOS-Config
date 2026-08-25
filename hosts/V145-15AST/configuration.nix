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
    ../../common/system/shell.nix
    ../../common/system/programs.nix
    ../../common/system/users.nix
    ../../profiles/plasma.nix
  ];

  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;

  system.stateVersion = "26.05";
}
