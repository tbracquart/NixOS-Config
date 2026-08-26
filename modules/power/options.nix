{ lib, ... }:

{
  options.my.power.batteryChargeLimit = lib.mkOption {
    type = lib.types.nullOr (lib.types.ints.between 0 100);
    default = null;
    description = "Limite de charge de la batterie en pourcentage.";
  };
}
