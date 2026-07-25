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
    printing = {
      enable = true;
      drivers = [ pkgs.hplip ]; # requis pour l'imprimante HP Deskjet
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    howdy= {
      enable = true;
    };

    openssh.enable = true;

    flatpak.enable = true;

    gpm.enable = true;
  };

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
