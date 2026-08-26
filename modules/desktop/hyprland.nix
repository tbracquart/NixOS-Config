{ pkgs, ... }:

{
  services.libinput.enable = true;

  programs.hyprland.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "gtk";
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
