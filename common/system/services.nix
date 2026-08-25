{ config, pkgs, lib, ... }:

{
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
    fwupd.enable = true;
  };

  location.provider = "geoclue2";
}
