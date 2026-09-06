{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  isoImage.volumeID = "NIXOS_CONFIG_INSTALLER";
  isoImage.isoName = "nixos-config-installer.iso";
}
