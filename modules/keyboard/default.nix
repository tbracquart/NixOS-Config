{ lib, ... }:

{
  options.my.keyboard = {
    layout = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Le layout XKB sélectionné par la configuration clavier.";
    };

    xkbConfigRoot = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "La racine XKB fournie par la configuration clavier.";
    };
  };

  imports = [
    ./global.nix
  ];
}
