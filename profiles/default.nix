{ lib, ... }:

{
  options.my.profile = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum [
      "laptop"
    ]);
    default = null;
    description = "Profil de la machine.";
  };

  imports = [
    ./laptop.nix
  ];
}
