{ modulesPath, ... }:
{
  imports = [
    # Profil utilisé par le job iso_minimal officiel de nixpkgs.
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal-combined.nix")
  ];

  isoImage.volumeID = "NIXOS_CONFIG_INSTALLER";
  isoImage.isoName = "nixos-config-installer.iso";
}
