{ config, pkgs, lib, ... }:

let
  cfg = config.my.power;
in
{
  options.my.power.batteryChargeLimit = lib.mkOption {
    type = lib.types.nullOr (lib.types.ints.between 0 100);
    default = null;
    description = "Limite de charge de la batterie en pourcentage.";
  };

  config = lib.mkIf (cfg.batteryChargeLimit != null) {
    systemd.services.battery-charge-threshold = {
      description = "Limiter la charge de la batterie";
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "set-charge-threshold" ''
          echo ${toString cfg.batteryChargeLimit} > /sys/class/power_supply/BAT0/charge_control_end_threshold
        ''}";
        RemainAfterExit = true;
      };
    };
  };
}
