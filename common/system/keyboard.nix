{ pkgs, ... }:

let
  xkbDir = pkgs.runCommand "azerty-global-xkb" { } ''
    cp -r --no-preserve=mode "${pkgs.xkeyboard_config}/etc/X11/xkb" "$out"
    chmod -R u+w "$out"
    cp ${./azerty_global} "$out/symbols/global"
  '';
in
{
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
}
