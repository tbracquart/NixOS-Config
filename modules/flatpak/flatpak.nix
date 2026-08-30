{ config, lib, ... }:

let
  cfg = config.my.flatpak;
in
{
  options.my.flatpak.enable = lib.mkEnableOption
    "Installation du service flatpak";

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;
  };
}
