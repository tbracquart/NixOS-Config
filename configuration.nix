{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/system.nix
    ./modules/services.nix
    ./modules/users.nix
    ./modules/programs.nix
    ./modules/hyprland.nix
    ./kdeconnect-openfirewall.nix
  ];

  disabledModules = [ "programs/kdeconnect.nix" ];


  virtualisation.vmVariant = {
    # Définit un mot de passe temporaire pour votre utilisateur, uniquement dans la VM
    users.users.thibaut.initialPassword = "test";
  };


  system.stateVersion = "26.05";
}
