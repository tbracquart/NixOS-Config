{ config, pkgs, lib, ... }:

let
  limit = config.my.power.batteryChargeLimit;
in
{
  config = lib.mkIf (limit != null) {
    systemd.services.battery-charge-threshold = {
      description = "Limiter la charge de la batterie";
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "set-charge-threshold" ''
          echo ${toString limit} > /sys/class/power_supply/BAT0/charge_control_end_threshold
        ''}";
        RemainAfterExit = true;
      };
    };
  };
}
