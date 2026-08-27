{ lib, ... }:

{
  options.my.keyboard.layout = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "Le layout XKB sélectionné par la configuration clavier.";
  };

  imports = [
    ./global.nix
  ];
}
