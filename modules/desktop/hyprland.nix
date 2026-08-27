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

  config = lib.mkIf cfg.enable (
    {
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
    }
    // lib.optionalAttrs (config.my.keyboard.xkbConfigRoot != null) {
      services.greetd.settings.default_session.command = lib.mkForce
        "env XKB_CONFIG_ROOT=${config.my.keyboard.xkbConfigRoot} ${config.programs.noctalia-greeter.package}/bin/noctalia-greeter-session -- ${config.programs.noctalia-greeter.greeter-args}";
    }
  );
}
