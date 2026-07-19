# Module kdeconnect avec l'option openFirewall, en attendant le merge de la PR :
# https://github.com/NixOS/nixpkgs/pull/543442
#
# ⚠️ À RETIRER une fois la PR mergée dans le nixpkgs officiel utilisé par ce
# système (sinon conflit : l'option serait définie deux fois). Pour vérifier,
# chercher "openFirewall" dans nixos/modules/programs/kdeconnect.nix du
# nixpkgs officiel.

{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.programs.kdeconnect = {
    enable = lib.mkEnableOption ''
      kdeconnect.

      Note that it will open the TCP and UDP port from
      1714 to 1764 as they are needed for it to function properly.
      You can use the {option}`package` to use
      `gnomeExtensions.gsconnect` as an alternative
      implementation if you use Gnome
    '';
    package = lib.mkPackageOption pkgs [ "kdePackages" "kdeconnect-kde" ] {
      nullable = true;
      example = "gnomeExtensions.gsconnect";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to open the TCP and UDP ports (1714-1764) needed by
        KDE Connect. Useful to disable when the package itself is
        installed elsewhere (e.g. via Home Manager) and only the
        system-level firewall rule is needed here.
      '';
    };
  };
  config =
    let
      cfg = config.programs.kdeconnect;
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = lib.optionals (cfg.package != null) [
        cfg.package
      ];
      networking.firewall = lib.mkIf cfg.openFirewall rec {
        allowedTCPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
        ];
        allowedUDPPortRanges = allowedTCPPortRanges;
      };
    };
}
