{ config, lib, ... }:

let
  cfg = config.my.firmware.redistributable;
in
{
  options.my.firmware.redistributable.enable = lib.mkEnableOption
    "le firmware redistribuable";

  config = lib.mkIf cfg.enable {
    hardware.enableRedistributableFirmware = true;
  };
}
