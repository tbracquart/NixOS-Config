{ config, pkgs, ... }:

{
  # Noctalia (symlink hors store)
  home.file.".local/state/noctalia/settings.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.my.flakePath}/common/modules/home/mutable-configs/noctalia-settings.toml";

  # Hyprland (config Lua hors store)
  home.file.".config/hypr/init.lua".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.my.flakePath}/common/modules/home/mutable-configs/hyprland.lua";

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    systemd.enable = true;
    extraConfig = ''require("init")'';
  };
}
