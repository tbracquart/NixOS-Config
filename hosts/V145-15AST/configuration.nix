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
    ../../common/system/services.nix
    ../../profiles/plasma.nix
  ];

  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [ ];

  system.stateVersion = "26.05";
}
