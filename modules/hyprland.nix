{ pkgs, ... }:

{
  # ==========================================
  #  HYPRLAND (dual-config avec KDE Plasma)
  # ==========================================

  programs.hyprland = {
    enable = true;
    withUWSM = true;      # intégration systemd propre, cohabite avec SDDM + Plasma
    xwayland.enable = true;
  };

  # Electron/Chromium en Wayland natif
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    kitty          # requis par la config par défaut de Hyprland
  ];
}
