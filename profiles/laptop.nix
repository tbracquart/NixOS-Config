{ config, lib, ... }:

{
  config = lib.mkIf (config.my.profile == "laptop") {
    my.bluetooth.enable = lib.mkDefault true;
    my.power.batteryChargeLimit = lib.mkDefault 80;
  };
}
