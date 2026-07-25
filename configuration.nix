{ config, pkgs, ... }:

let
  noctalia-src = builtins.fetchTarball {
    url = "https://github.com/noctalia-dev/noctalia/archive/cachix.tar.gz";
    sha256 = "003bdgvig2nsbr5688diwz08yr9i5h0hmfwm1r4z4gxn3smw9bwa";
  };
in
{
  nix.settings = {
    substituters = [ "https://noctalia.cachix.org" ];
    trusted-public-keys = [ "noctalia.cachix.org-1:Q+Yc4k8bqOUb5hbZB30DoePrspQ2qrm/WcB1MsOa3wE=" ];
  };

  # 👇 OPTIONNEL MAIS RECOMMANDÉ pour Hyprland + Noctalia
  programs.hyprland.withUWSM = true;

  # ... le reste de ta config

  imports = [
    "${noctalia-src}/nix/nixos-module.nix"
    ./hardware-configuration.nix
    ./modules/system.nix
    ./modules/services.nix
    ./modules/users.nix
    ./modules/programs.nix
    ./modules/hyprland.nix
    ./kdeconnect-openfirewall.nix
  ];

  programs.noctalia = {
    enable = true;
    # Optionnel : configurer le service systemd
    # systemd.enable = true;
  };

  disabledModules = [ "programs/kdeconnect.nix" ];

  system.stateVersion = "26.05";
}
