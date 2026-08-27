{ config, lib, ... }:

let
  cfg = config.my.authentication.howdy;
in
{
  options.my.authentication.howdy.enable = lib.mkEnableOption
    "l'authentification faciale avec Howdy";

  config = lib.mkIf cfg.enable {
    services.howdy = {
      enable = true;
      control = "sufficient";
    };

    # Désactivation de Howdy pour Polkit conservée temporairement pour test.
    # security.pam.services.polkit-1.howdy.enable = false;
  };
}
