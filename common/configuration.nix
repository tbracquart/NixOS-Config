{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.noctalia-greeter.nixosModules.default

    ./modules/system/01-nix.nix
    ./modules/system/02-boot.nix
    ./modules/system/03-hardware.nix
    ./modules/system/04-networking.nix
    ./modules/system/05-desktop.nix
    ./modules/system/06-users.nix
    ./modules/system/07-packages.nix
    ./modules/system/08-virtualisation.nix
  ];

  system.stateVersion = "26.05";
}
