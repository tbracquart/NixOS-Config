{ lib, ... }:

{
  my.bluetooth.enable = lib.mkDefault true;
  my.power.batteryChargeLimit = lib.mkDefault 80;
}
