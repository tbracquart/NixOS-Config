{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./variables.nix
    ./users.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ ];

  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = { enable = true; addresses = true; };
  };

  networking.networkmanager.enable = true;

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    fastfetch
  ];

  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        fastfetch

        function clr
          clear
          fastfetch
        end
      '';
    };

    kdeconnect.enable = true;
    git = {
      enable = true;
      config = {
        user.name = "Thibaut Bracquart";
        user.email = "202062783+tbracquart@users.noreply.github.com";
      };
    };
  };

  services.openssh.enable = true;
  services.flatpak.enable = true;

  system.stateVersion = "26.05";
}
