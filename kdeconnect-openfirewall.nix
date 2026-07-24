# Module kdeconnect avec l'option openFirewall (découplage réel enable/openFirewall),
# en attendant le merge de la PR : https://github.com/NixOS/nixpkgs/pull/543442
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

      Note that by default it will open the TCP and UDP ports from
      1714 to 1764 as they are needed for it to function properly.
      See {option}`openFirewall` to control this behavior.
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
        Whether to open the required TCP and UDP ports (1714-1764) needed by KDE Connect.
      '';
    };
  };
  config = lib.mkMerge [
    (lib.mkIf config.programs.kdeconnect.enable {
      environment.systemPackages = lib.optionals (config.programs.kdeconnect.package != null) [
        config.programs.kdeconnect.package
      ];
    })
    (lib.mkIf config.programs.kdeconnect.openFirewall (
      let
        allowedTCPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
        ];
      in
      {
        networking.firewall = {
          inherit allowedTCPPortRanges;
          allowedUDPPortRanges = allowedTCPPortRanges;
        };
      }
    ))
  ];
}
