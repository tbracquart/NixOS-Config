{ config, pkgs, ... }:

let
  noctalia-src = builtins.fetchTarball {
    url = "https://github.com/noctalia-dev/noctalia/archive/cachix.tar.gz";
    sha256 = "003bdgvig2nsbr5688diwz08yr9i5h0hmfwm1r4z4gxn3smw9bwa";
  };
  # `default.nix` du repo Noctalia expose nixosModule/homeModule/hjemModule
  # avec `package` déjà câblé dessus (programs.noctalia.package = mkDefault
  # package;). Importer directement nix/nixos-module.nix (comme avant) laisse
  # `package` à `null`, donc rien n'est jamais installé.
  noctalia = import noctalia-src { inherit pkgs; };
in
{
  nix.settings = {
    substituters = [ "https://noctalia.cachix.org" ];
    trusted-public-keys = [ "noctalia.cachix.org-1:Q+Yc4k8bqOUb5hbZB30DoePrspQ2qrm/WcB1MsOa3wE=" ];
  };

  imports = [
    noctalia.nixosModule
    ./hardware-configuration.nix
    ./modules/system.nix
    ./modules/services.nix
    ./modules/users.nix
    ./modules/programs.nix
    ./modules/hyprland.nix
    ./kdeconnect-openfirewall.nix
  ];

  # Le paquet est déjà fourni par `noctalia.nixosModule` (voir ci-dessus).
  # Le lancement effectif se fait via le compositeur (voir
  # Home-Manager-Config/modules/desktop/hyprland.nix,
  # hl.on("hyprland.start", ...)), qui est la méthode officiellement
  # recommandée par Noctalia (le démarrage via service systemd est déprécié).
  #
  # ⚠️ systemd.enable est volontairement laissé désactivé (par défaut) :
  # le démarrage via service systemd est déprécié côté Noctalia et peut
  # créer une double instance si le compositeur le lance aussi.
  programs.noctalia = {
    enable = true;
  };

  disabledModules = [ "programs/kdeconnect.nix" ];

  system.stateVersion = "26.05";
}
