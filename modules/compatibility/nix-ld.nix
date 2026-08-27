{ config, lib, ... }:

let
  cfg = config.my.compatibility.nix-ld;
in
{
  options.my.compatibility.nix-ld.enable = lib.mkEnableOption
    "la compatibilité des binaires dynamiques avec nix-ld";

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = true;
  };
}
