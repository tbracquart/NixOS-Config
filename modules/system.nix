{ config, pkgs, ... }:

{
  # ==========================================
  #  BOOT & KERNEL
  # ==========================================

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };

    kernelPackages = pkgs.linuxPackages_zen; 
    kernelParams = [ "quiet" "splash" "i915.force_probe=!9a49" "xe.force_probe=9a49" ];
    consoleLogLevel = 3; 

    plymouth = { enable = true; theme = "bgrt"; };

    initrd = {
      kernelModules = [ "xe" ];
      systemd.enable = true;
      verbose = false;
    };
  };

  # ==========================================
  #  RÉSEAU & LOCALISATION
  # ==========================================

  networking = {
    hostName = "NixOS";
    networkmanager.enable = true;
    firewall.enable = true;
    firewall.allowedUDPPorts = [ 5353 ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  time.timeZone = "Europe/Paris";

  i18n = {
    defaultLocale = "fr_FR.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };
  };

  console.keyMap = "fr";
}
