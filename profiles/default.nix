{ lib, config, ... }:

{
  imports = [
    ./laptop.nix
  ];

  options.my.profile = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum [ "laptop" ]);
    default = null;
    description = "Profil matériel et fonctionnel de la machine.";
  };

  config.assertions = [
    {
      assertion = config.my.profile != null;
      message = "Chaque host doit déclarer un profil avec my.profile.";
    }
  ];
}
