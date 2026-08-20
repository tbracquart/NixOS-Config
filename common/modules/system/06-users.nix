{ config, pkgs, lib, ... }:

{
  users.users.thibaut = {
    isNormalUser = true;
    description = "Thibaut Bracquart";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    shell = pkgs.fish;
  };
}
