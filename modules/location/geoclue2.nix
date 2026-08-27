{ config, lib, ... }:

let
  cfg = config.my.location.geoclue2;
in
{
  options.my.location.geoclue2.enable = lib.mkEnableOption
    "les services de géolocalisation GeoClue2";

  config = lib.mkIf cfg.enable {
    services.geoclue2 = {
      enable = true;
      geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
    };

    location.provider = "geoclue2";
  };
}
