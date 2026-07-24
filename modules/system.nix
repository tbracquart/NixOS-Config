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

    kernelPackages = pkgs.linuxPackages_latest;
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
  #  GPU (ACCÉLÉRATION MATÉRIELLE - INTEL XE)
  # ==========================================

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver     # VA-API (iHD) - requis pour Xe/Arc
      vpl-gpu-rt              # oneVPL (QSV) runtime
      intel-compute-runtime   # OpenCL / Level Zero
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # force le backend moderne iHD (au lieu de i965)
  };

  # ==========================================
  #  FIRMWARE (WIFI/BLUETOOTH, MICROCODE)
  # ==========================================

  hardware.enableRedistributableFirmware = true;
  # Note : hardware.wirelessRegulatoryDatabase (régulation WiFi) est activé
  # automatiquement par enableRedistributableFirmware, pas besoin de le forcer.
  # Note : sof-firmware (son Tiger Lake) est aussi inclus automatiquement ici.

  # ==========================================
  #  AUDIO — CONTOURNEMENT CONNU (TIGER LAKE + SOF)
  # ==========================================
  # Bug documenté (kernel/thesofproject) sur les puces audio Tiger Lake :
  # le son peut disparaître après une veille. Pas garanti de se produire
  # sur ce système précis (dépend du kernel). Si ça arrive, décommenter :
  #
  # powerManagement.resumeCommands = ''
  #   ${pkgs.kmod}/bin/modprobe -r snd_sof_pci_intel_tgl
  #   ${pkgs.kmod}/bin/modprobe snd_sof_pci_intel_tgl
  # '';

  # ==========================================
  #  MISES À JOUR FIRMWARE (BIOS, CONTRÔLEURS)
  # ==========================================

  services.fwupd.enable = true;

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
    networkmanager = {
      enable = true;
      settings = { connection."wifi.powersave" = 2; };
    };

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

    services.geoclue2 = {
    enable = true;
    geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
  };

  location.provider = "geoclue2";

  # ===========================================
  #  AUTRE FONCTIONS
  # ==========================================

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
