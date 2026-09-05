{ pkgs, ... }:

{
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = { enable = true; addresses = true; };
    };

    fwupd.enable = true;
    gvfs.enable = true;
    openssh.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };
  };
}
