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
  #  BATTERIE
  # ==========================================

  systemd.services.battery-charge-threshold = {
    description = "Limiter la charge de la batterie à 80%";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "set-charge-threshold" ''
        echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold
      ''}";
      RemainAfterExit = true;
    };
  };

  # ==========================================
  #  RÉSEAU & LOCALISATION
  # ==========================================

  networking = {
    hostName = "ZenBook-13";
    networkmanager.enable = true;
    firewall.enable = true;
    firewall.allowedUDPPorts = [ ];
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = { enable = true; addresses = true; };
    };

    samba.enable = true;
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
