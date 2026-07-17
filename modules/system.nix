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

    dbus.packages = [
      (pkgs.writeTextFile {
        name = "geoclue-wpa-supplicant-dbus-policy";
        destination = "/etc/dbus-1/system.d/geoclue-wpa-supplicant.conf";
        text = ''
          <!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
           "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
          <busconfig>
            <policy user="geoclue">
              <allow receive_sender="fi.w1.wpa_supplicant1" receive_type="signal"/>
              <allow send_destination="fi.w1.wpa_supplicant1" send_interface="org.freedesktop.DBus.Properties" send_member="Get"/>
              <allow send_destination="fi.w1.wpa_supplicant1" send_interface="org.freedesktop.DBus.Properties" send_member="GetAll"/>
              <allow send_destination="fi.w1.wpa_supplicant1" send_interface="org.freedesktop.DBus.Introspectable"/>
              <allow send_destination="fi.w1.wpa_supplicant1" send_interface="fi.w1.wpa_supplicant1.Interface" send_type="method_call" send_member="Scan"/>
            </policy>
          </busconfig>
        '';
      })
    ];

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

    services.geoclue2 = {
    enable = true;
    geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
  };

  location.provider = "geoclue2";
}
