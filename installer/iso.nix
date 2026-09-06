{ modulesPath, pkgs, repoSource, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ./service.nix
  ];
  isoImage.volumeID = "NIXOS_CONFIG_INSTALLER";
  isoImage.isoName = "nixos-config-installer.iso";

  # Le profil minimal upstream construit une ISO démarrable ; nous ajoutons
  # simplement le dépôt et notre installateur par-dessus.

  # Instantané du dépôt utilisé pour construire cette ISO.
  environment.etc."nixos-config".source = repoSource;

  # Outils nécessaires aux prochaines étapes de l'installateur personnalisé.
  environment.systemPackages = with pkgs; [
    git
    nixos-facter
    parted
    util-linux
  ];
}
