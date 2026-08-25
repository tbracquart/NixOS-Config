{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./variables.nix
    ./users.nix

    ../../common/system/nix.nix
    ../../common/system/boot.nix
    ../../common/system/networking.nix
    ../../common/system/locale.nix
    ../../common/system/services.nix
    ../../profiles/laptop.nix
    ../../modules/power/options.nix
    ../../modules/power/module.nix

    inputs.noctalia-greeter.nixosModules.default
  ];

  system.stateVersion = "26.05";
}
