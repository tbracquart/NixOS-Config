{ config, pkgs, lib, ... }:

let
  cfg = config.my.power;
  setChargeThreshold = pkgs.writeShellScript "set-battery-charge-threshold" ''
    set -eu

    found=0

    for battery in /sys/class/power_supply/*; do
      [ -f "$battery/type" ] || continue
      [ "$(cat "$battery/type")" = "Battery" ] || continue

      threshold="$battery/charge_control_end_threshold"
      [ -e "$threshold" ] || continue

      echo ${toString cfg.batteryChargeLimit} > "$threshold"
      found=1
    done

    if [ "$found" -eq 0 ]; then
      echo "Aucune interface de seuil de charge compatible n'a été trouvée." >&2
      exit 1
    fi
  '';
in
{
  options.my.power.batteryChargeLimit = lib.mkOption {
    type = lib.types.nullOr (lib.types.ints.between 1 100);
    default = null;
    description = "Limite de charge de la batterie en pourcentage (de 1 à 100).";
  };

  config = lib.mkIf (cfg.batteryChargeLimit != null) {
    systemd.services.battery-charge-threshold = {
      description = "Limiter la charge de la batterie";
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = setChargeThreshold;
        RemainAfterExit = true;
      };
    };
  };
}
