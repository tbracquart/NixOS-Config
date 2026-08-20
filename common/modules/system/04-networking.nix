{ config, pkgs, lib, ... }:

{
  networking = {
    hostName = "ZenBook-13";
    networkmanager = {
      enable = true;
      settings = { connection."wifi.powersave" = 2; };
    };
    firewall.enable = true;
  };

  systemd.services.NetworkManager-wait-online.enable = false;

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

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = { enable = true; addresses = true; };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };

    openssh.enable = true;
    flatpak.enable = true;
    geoclue2 = {
      enable = true;
      geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
    };
    greetd.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
  };

  location.provider = "geoclue2";

  # Batterie
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
}
