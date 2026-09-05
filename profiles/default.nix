{ lib, ... }:

{
  imports = [
    ./laptop.nix
  ];

  options.my.profile = lib.mkOption {
    type = lib.types.enum [ "laptop" ];
    description = "Profil matériel et fonctionnel de la machine.";
  };
}
