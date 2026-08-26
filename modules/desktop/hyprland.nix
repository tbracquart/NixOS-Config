{ config, inputs, pkgs, lib, ... }:

let
  cfg = config.my.desktop.hyprland;
in
{
  options.my.desktop.hyprland.enable = lib.mkEnableOption
    "l'environnement de bureau Hyprland";

  config = lib.mkIf cfg.enable {
    imports = [
      inputs.noctalia-greeter.nixosModules.default
    ];

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
        keyboard.layout = "global";
        output.scale = 1;
      };
    };
  };
}
