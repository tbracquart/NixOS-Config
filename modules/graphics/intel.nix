{ config, lib, pkgs, ... }:

let
  cfg = config.my.graphics.intel;
in
{
  options.my.graphics.intel.enable = lib.mkEnableOption
    "le support graphique Intel";

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vpl-gpu-rt
      ];
    };

    environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  };
}
