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

    flatpak.enable = true;

#     dbus.packages = [
#       (pkgs.writeTextFile {
#         name = "geoclue-wpa-supplicant-dbus-policy";
#         destination = "/etc/dbus-1/system.d/geoclue-wpa-supplicant.conf";
#         text = ''
#           <!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
#            "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
#           <busconfig>
#             <policy user="geoclue">
#               <allow receive_sender="fi.w1.wpa_supplicant1" receive_type="signal"/>
#               <allow send_destination="fi.w1.wpa_supplicant1" send_interface="org.freedesktop.DBus.Properties" send_member="Get"/>
#               <allow send_destination="fi.w1.wpa_supplicant1" send_interface="org.freedesktop.DBus.Properties" send_member="GetAll"/>
#               <allow send_destination="fi.w1.wpa_supplicant1" send_interface="org.freedesktop.DBus.Introspectable"/>
#               <allow send_destination="fi.w1.wpa_supplicant1" send_interface="fi.w1.wpa_supplicant1.Interface" send_type="method_call" send_member="Scan"/>
#             </policy>
#           </busconfig>
#         '';
#       })
#     ];

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
