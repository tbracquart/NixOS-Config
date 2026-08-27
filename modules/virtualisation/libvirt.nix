{ config, lib, ... }:

let
  cfg = config.my.virtualisation.libvirt;
in
{
  options.my.virtualisation.libvirt = {
    enable = lib.mkEnableOption "la virtualisation avec libvirt";

    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Utilisateur à ajouter au groupe libvirtd.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;
    })

    (lib.mkIf (cfg.enable && cfg.user != null) {
      users.users.${cfg.user}.extraGroups = [ "libvirtd" ];
    })
  ];
}
