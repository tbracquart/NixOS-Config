{ config, ... }:

{
  home.file.".local/state/noctalia/settings.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.my.flakePath}/users/thibaut/hyprland/mutable-configs/noctalia-settings.toml";

  home.file.".config/hypr/init.lua".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.my.flakePath}/users/thibaut/hyprland/mutable-configs/hyprland.lua";

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    systemd.enable = true;
    extraConfig = ''require("init")'';
  };
}
