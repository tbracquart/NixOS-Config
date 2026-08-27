{ config, inputs, pkgs, lib, ... }:

let
  cfg = config.my.desktop.hyprland;
in
{
  imports = [
    inputs.noctalia-greeter.nixosModules.default
  ];

  options.my.desktop.hyprland.enable = lib.mkEnableOption
    "le gestionnaire de fenêtres Hyprland";

  config = lib.mkIf cfg.enable {
    services.libinput.enable = true;

    programs.hyprland.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = "gtk";
    };

    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };

    programs.noctalia-greeter = {
      enable = true;
      settings = {
        output.scale = 1;
      } // lib.optionalAttrs (config.my.keyboard.layout != null) {
        keyboard.layout = config.my.keyboard.layout;
      };
    };
  };
}
