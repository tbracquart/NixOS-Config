{ config, pkgs, ... }:

# let
#   home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz";
# in

{
  imports = [ 
    ./hardware-configuration.nix
    ./modules/system.nix
    ./modules/services.nix
    ./modules/users.nix
    ./modules/programs.nix
#     (import "${home-manager}/nixos")
  ];

#   home-manager.users.thibaut = import ./home/thibaut.nix;

  system.stateVersion = "26.05";
}
