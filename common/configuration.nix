{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.noctalia-greeter.nixosModules.default
  ];

  # ============================================================================
  # 1. PARAMÈTRES NIX, FLAKES & CACHES BINAIRES (CACHIX)
  # ============================================================================
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      
      # Autorise root et thibaut à faire confiance aux substituts des Flakes
      trusted-users = [ "root" "thibaut" ];

      # Serveurs de cache binaire pour éviter de tout recompiler
      substituters = [
        "https://tbracquart.cachix.org"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://attic.xuyh0120.win/lantian"
        "https://freesmlauncher.cachix.org"
        "https://noctalia.cachix.org"
      ];

      # Clés de sécurité publiques
      trusted-public-keys = [
        "tbracquart.cachix.org-1:eTT16nwdreuvu4yagVFB1p+PeRg8ZCZsCA8648IJCZU="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "freesmlauncher.cachix.org-1:Jcp5Q9wiLL+EDv8Mh7c6L9xGk+lXr7/otpKxMOuBuDs="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];

      # Token GitHub (déchiffré via sops-nix) pour éviter le rate-limit
      # anonyme de l'API GitHub lors du fetch des flake inputs.
      netrc-file = "/run/secrets/github-netrc";
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # ============================================================================
  # 1bis. SECRETS (SOPS-NIX)
  # ============================================================================
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;

    # Réutilise la clé hôte SSH ed25519 existante, convertie en clé age.
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets."github-netrc" = {
      # Rend le secret déchiffré lisible par Nix (root uniquement) avant
      # que nixos-rebuild ne lise nix.conf.
      path = "/run/secrets/github-netrc";
      mode = "0400";
    };

    # Token Cachix (chiffré dans ../secrets/secrets.yaml)
    secrets."cachix-auth-token" = {
      path = "/run/secrets/cachix-auth-token";
      mode = "0400";
    };
  };

  # Activation script : enregistre le token avec cachix authtoken (thibaut)
  system.activationScripts.cachixAuthtoken = {
    text = ''
      if [ -f /run/secrets/cachix-auth-token ]; then
        if id -u thibaut >/dev/null 2>&1; then
          mkdir -p /home/thibaut/.config/cachix
          cat /run/secrets/cachix-auth-token | runuser -u thibaut -- ${pkgs.cachix}/bin/cachix authtoken --stdin || true
          chown -R thibaut:users /home/thibaut/.config/cachix
        fi
      fi
    '';
  };

  # ============================================================================
  # 2. BOOT, NOYAU & INTEL XE
  # ============================================================================
  boot = {
    loader = {
      limine = {
        enable = true;
        maxGenerations = 20;
        style = {
          wallpapers = [
            (pkgs.fetchurl {
              name = "nix-wallpaper.png";
              url = "https://wallpaperaccess.com/full/23970580.jpg";
              hash = "sha256-5DcL/eP6BYg8NIhVDxrgRiyt4EYd5dg6bBShzpYqUWE=";
            })
          ];
          wallpaperStyle = "stretched";
        };
      };

      efi.canTouchEfiVariables = true;
      timeout = 1;
    };

    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore;
    kernelParams = [ "i915.force_probe=!9a49" "xe.force_probe=9a49" "loglevel=3" "rd.systemd.show_status=false" ];
    consoleLogLevel = 3;

    # Support de l'hibernation (Resume) & déverrouillage de la Swap LUKS
    resumeDevice = "/dev/mapper/luks-a0f369c9-319a-4e22-ac5f-7b5a191b22e8";

    plymouth = {
      enable = true;
      theme = "bgrt";
    };

    initrd = {
      kernelModules = [ "xe" ];
      systemd.enable = true;
      verbose = false;
      
      # Déverrouillage de la partition SWAP chiffrée lors du boot/initrd
      luks.devices."luks-a0f369c9-319a-4e22-ac5f-7b5a191b22e8".device = "/dev/disk/by-uuid/a0f369c9-319a-4e22-ac5f-7b5a191b22e8";
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
    samba.enable = false;
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
    greetd.enable = true;
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
  services.libinput.enable = true;

  programs.hyprland.enable = true;
  programs.niri.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
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
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    shell = pkgs.fish;
  };

  # ============================================================================
  # 8. PROGRAMMES & PAQUETS SYSTÈME
  # ============================================================================
  nixpkgs.config.allowUnfree = true;

  environment = {
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
      dnsmasq
      alacritty
      adw-gtk3
      qt6Packages.qt6ct
      cachix
      sops
      ssh-to-age
      thunar
    ];
  };

  # Thème Qt piloté par qt5ct/qt6ct (eux-mêmes thémés par Noctalia via le
  # template "qt"). Note : la valeur d'énum accepté par NixOS est "qt5ct"
  # même si elle pilote aussi qt6ct — c'est le nom historique de l'option.
  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

  programs = {
    fish.enable = true;
    vim = { enable = true; defaultEditor = true; };
    kdeconnect.enable = true;
    noctalia-greeter = { enable = true; settings = { keyboard.layout = "fr"; output.scale = 1; }; };
    nix-ld.enable = true;
  };

  # ============================================================================
  # 9. VIRTUALISATION (LIBVIRT/QEMU)
  # ============================================================================
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # ============================================================================
  # 10. VERSION DU SYSTÈME
  # ============================================================================
  system.stateVersion = "26.05";
}
