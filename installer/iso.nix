{ modulesPath, pkgs, ... }:
{
  imports = [
    # Profil officiel de l'image d'installation minimale NixOS.
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  isoImage.volumeID = "NIXOS_CONFIG_INSTALLER";
  isoImage.isoName = "nixos-config-installer.iso";

  # Outils nécessaires aux prochaines étapes de l'installateur personnalisé.
  environment.systemPackages = with pkgs; [
    git
    nixos-facter
  ];
}
