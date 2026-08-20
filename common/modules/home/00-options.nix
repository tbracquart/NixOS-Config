{ config, lib, ... }:

{
  options.my = {
    flakePath = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/nixos-config--modularize-common-config";
      description = "Chemin absolu vers le dépôt nixos-config";
    };
  };
}
