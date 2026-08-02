{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # ============================================================================
  # NIX & FLAKES
  # ============================================================================
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ ];

  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;

  networking.hostName = "V145-15AST"; # Define your hostname.

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = { enable = true; addresses = true; };
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";

  i18n.extraLocaleSettings = {
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define user accounts. Don't forget to set a password with 'passwd'.
  users.users = {
    "quentin" = {
      isNormalUser = true;
      description = "Quentin Bracquart";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.fish;
      packages = with pkgs; [
        kdePackages.kate
      ];
    };

    "thibaut" = {
      isNormalUser = true;
      description = "Thibaut Bracquart";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.fish;
      packages = with pkgs; [ ];
    };
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
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

  # List services that you want to enable:
  services.openssh.enable = true;
  services.flatpak.enable = true;

  system.stateVersion = "26.05";
}
