{ modulesPath, pkgs, repoSource, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ./service.nix
  ];
  isoImage.volumeID = "NIXOS_CONFIG_INSTALLER";
  isoImage.isoName = "nixos-config-installer.iso";

  # Instantané du dépôt utilisé pour construire cette ISO.
  environment.etc."nixos-config".source = repoSource;

  # Outils nécessaires aux prochaines étapes de l'installateur personnalisé.
  environment.systemPackages = with pkgs; [
    git
    nixos-facter
  ];
}
