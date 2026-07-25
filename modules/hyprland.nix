{ config, pkgs, ... }:

{
  # ==========================================
  #  HYPRLAND (compositeur Wayland)
  # ==========================================

  # UWSM : lance Hyprland dans une session systemd correctement scopée
  # (nécessaire pour une bonne intégration avec les portails XDG et Noctalia).
  # Avec withUWSM = true, Home Manager ne doit PAS gérer son propre service
  # systemd pour Hyprland (voir modules/desktop/hyprland.nix côté Home Manager,
  # wayland.windowManager.hyprland.systemd.enable = false).
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # XDG Desktop Portal : nécessaire pour le partage d'écran, les file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # ⚠️ Pas de `services.displayManager.defaultSession` ici : on veut garder
  # KDE Plasma 6 (SDDM) ET Hyprland disponibles au choix depuis SDDM, sans
  # imposer l'un ou l'autre par défaut. Les deux sessions apparaîtront dans
  # le sélecteur SDDM automatiquement (Plasma via desktopManager.plasma6,
  # Hyprland via programs.hyprland.enable).
}
