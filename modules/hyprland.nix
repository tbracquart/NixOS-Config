{ config, pkgs, ... }:

{
  # 1. Activer le module NixOS pour Hyprland
  programs.hyprland.enable = true;

  # 2. Optionnel mais recommandé : meilleure intégration XDG Portal
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  
  # 3. Définir la session Hyprland pour ton Display Manager (SDDM)
  services.displayManager.defaultSession = "hyprland";
  
  # 4. Si tu veux utiliser SDDM avec Hyprland, c'est déjà bon.
  #    Sinon, tu peux aussi ajouter Hyprland comme session:
  # services.displayManager.session = [{
  #   manage = "desktop";
  #   name = "hyprland";
  #   start = "exec Hyprland";
  # }];
}
