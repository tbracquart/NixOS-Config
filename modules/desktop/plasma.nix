{ config, lib, ... }:

let
  cfg = config.my.desktop.plasma;
in
{
  options.my.desktop.plasma.enable = lib.mkEnableOption
    "l'environnement de bureau Plasma";

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
  };
}
