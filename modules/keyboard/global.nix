{ config, lib, pkgs, ... }:

let
  cfg = config.my.keyboard.global;
  xkbDir = pkgs.runCommand "azerty-global-xkb" { } ''
    mkdir -p "$out"
    cp -rL --no-preserve=mode "${pkgs.xkeyboard_config}/etc/X11/xkb/." "$out/"
    cp ${./azerty_global} "$out/symbols/global"
  '';
in
{
  options.my.keyboard.global.enable = lib.mkEnableOption
    "le clavier AZERTY Global";

  config = lib.mkIf cfg.enable {
    services.xserver.xkb = {
      dir = xkbDir;
      layout = "global";
      variant = "";
    };

    console.useXkbConfig = true;

    environment.sessionVariables = {
      XKB_CONFIG_ROOT = xkbDir;
      XKB_DEFAULT_LAYOUT = "global";
      XKB_DEFAULT_VARIANT = "";
    };
  };
}
