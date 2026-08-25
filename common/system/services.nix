{ pkgs, ... }:

{
  services.pulseaudio.enable = false;

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
    udisks2.enable = true;
    gvfs.enable = true;
    fwupd.enable = true;
  };
}
