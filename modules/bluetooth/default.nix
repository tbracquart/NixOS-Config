{ config, lib, ... }:

let
  cfg = config.my.bluetooth;
in
{
  options.my.bluetooth = {
    enable = lib.mkEnableOption "le Bluetooth";

    powerOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Activer le Bluetooth au démarrage.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = cfg.powerOnBoot;
    };
  };
}
