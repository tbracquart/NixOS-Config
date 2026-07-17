{ config, pkgs, ... }:

{
  # ==========================================
  #  SERVICES (X11, KDE, Audio, Impression, etc.)
  # ==========================================

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "fr";
        variant = "";
      };
    };

    libinput.enable = true;

    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    printing.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    howdy= {
      enable = true;
    };

    openssh.enable = true;
  };

  # =========================================
  #  RÉSEAU
  # =========================================

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  services.geoclue2 = {
    enable = true;
    geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
  };

  location.provider = "geoclue2";

  # ==========================================
  #  BLUETOOTH
  # ==========================================

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # ==========================================
  #  SÉCURITÉ
  # ==========================================

  security = {
    rtkit.enable = true;
    pam.howdy = {
      enable = true;
      control = "sufficient";
    };
  
  pam.services.polkit-1.howdy.enable = false;
  };
}
