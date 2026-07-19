{ config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ./modules/system.nix
    ./modules/services.nix
    ./modules/users.nix
    ./modules/programs.nix
    ./kdeconnect-openfirewall.nix
  ];

  disabledModules = [ "programs/kdeconnect.nix" ];

  system.stateVersion = "26.05";
}
