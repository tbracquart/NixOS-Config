{ config, lib, ... }:

let
  cfg = config.my.virtualisation.libvirt;
in
{
  options.my.virtualisation.libvirt.enable = lib.mkEnableOption
    "la virtualisation avec libvirt";

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
  };
}
