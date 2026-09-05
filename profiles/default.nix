{ lib, ... }:

let
  profiles = {
    laptop = ./laptop.nix;
  };
in
{
  options.my.profile = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum (builtins.attrNames profiles));
    default = null;
    description = "Profil de la machine.";
  };

  imports = builtins.attrValues profiles;
}
