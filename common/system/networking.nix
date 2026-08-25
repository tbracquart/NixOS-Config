{ config, pkgs, lib, ... }:

{
  networking = {
    networkmanager = {
      enable = true;
      settings = { connection."wifi.powersave" = 2; };
    };
    firewall.enable = true;
  };

  systemd.services.NetworkManager-wait-online.enable = false;
}
