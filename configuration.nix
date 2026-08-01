{ config, pkgs, lib, ... }:

{
  imports = [ ];

  # ============================================================================
  # 1. PARAMÈTRES NIX & FLAKES
  # ============================================================================
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
       automatic = true;
       dates = "weekly";
       options = "--delete-older-than 14d";
    };
  };

  # ============================================================================
  # 2. BOOT, NOYAU & INTEL XE
  # ============================================================================
  boot = {
    loader = {
      systemd-boot = { enable = true; configurationLimit = 15; };
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "quiet" "splash" "i915.force_probe=!9a49" "xe.force_probe=9a49" ];
    consoleLogLevel = 3;

    plymouth = {
      enable = true;
      theme = "bgrt";
    };

    initrd = {
      kernelModules = [ "xe" ];
      systemd.enable = true;
      verbose = false;
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # VA-API (iHD)
      vpl-gpu-rt          # oneVPL (QSV) runtime
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;

  # ============================================================================
  # 3. RÉSEAU, LOCALISATION & AUDIO
  # ============================================================================
  networking = {
    hostName = "ZenBook-13";
    networkmanager = {
      enable = true;
      settings = { connection."wifi.powersave" = 2; };
    };
    firewall.enable = true;
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

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = { enable = true; addresses = true; };
    };
    samba.enable = true;
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
    gpm.enable = true;
    geoclue2 = {
      enable = true;
      geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
    };
  };

  location.provider = "geoclue2";
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # ============================================================================
  # 4. GESTION DE LA BATTERIE (SEUIL 80%)
  # ============================================================================
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

  # ============================================================================
  # 5. SESSIONS GRAPHIQUES (KDE PLASMA 6, HYPRLAND & NOCTALIA)
  # ============================================================================
  services.xserver = {
    enable = true;
    xkb = {
      layout = "fr";
      variant = "";
    };
  };

  services.libinput.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  programs.noctalia = {
    enable = true;
  };

  # ============================================================================
  # 6. SÉCURITÉ & AUTHENTIFICATION (HOWDY)
  # ============================================================================
  services.howdy.enable = true;

  security = {
    rtkit.enable = true;
    pam.howdy = {
      enable = true;
      control = "sufficient";
    };
    pam.services.polkit-1.howdy.enable = false;
  };

  # ============================================================================
  # 7. UTILISATEUR & SHELL
  # ============================================================================
  users.users."thibaut" = {
    isNormalUser = true;
    description = "Thibaut Bracquart";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  # ============================================================================
  # 8. PROGRAMMES & PAQUETS SYSTÈME
  # ============================================================================
  nixpkgs.config.allowUnfree = true;

  environment = {
    shells = [ pkgs.fish ];
    systemPackages = with pkgs; [
      htop
      btop
      fastfetch
      pciutils
      tree
      file
      bat
      mpv
      ripgrep
    ];
  };

  programs = {
    fish.enable = true;
    firefox.enable = true;
    vim = {
      enable = true;
      defaultEditor = true;
    };
    kdeconnect.enable = false;
  };

  # ============================================================================
  # 9. VERSION DU SYSTÈME
  # ============================================================================
  system.stateVersion = "26.05";
}
