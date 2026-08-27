{ config, lib, ... }:

{
  config = lib.mkIf (config.my.profile == "laptop") {
    my.bluetooth.enable = true;
    my.bluetooth.powerOnBoot = true;
  };
}
