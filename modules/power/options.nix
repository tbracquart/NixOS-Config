{ lib, ... }:

{
  options.my.power.batteryChargeLimit = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "Limite de charge de la batterie en pourcentage.";
  };
}
