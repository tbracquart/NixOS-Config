{ config, pkgs, lib, ... }:

{
  services.libinput.enable = true;

  programs.hyprland.enable = true;
  programs.niri.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "gtk";
  };

  services.howdy.enable = true;

  security = {
    rtkit.enable = true;
    pam.howdy = {
      enable = true;
      control = "sufficient";
    };
    pam.services.polkit-1.howdy.enable = false;
  };

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  programs.noctalia-greeter = {
    enable = true;
    settings = {
      keyboard.layout = "global";
      output.scale = 1;
    };
  };
}
