{ modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ./service.nix
  ];
  isoImage.volumeID = "NIXOS_CONFIG_INSTALLER";
  isoImage.isoName = "nixos-config-installer.iso";
  environment.systemPackages = with pkgs; [ git nixos-facter ];
}
