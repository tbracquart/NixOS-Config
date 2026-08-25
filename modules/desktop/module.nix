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

  services.howdy.enable = true;

  security = {
    pam.howdy = {
      enable = true;
      control = "sufficient";
    };
    # Désactivation de Howdy pour Polkit conservée temporairement pour test.
    # pam.services.polkit-1.howdy.enable = false;
  };

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  programs.noctalia-greeter = {
    enable = true;
    settings = {
      keyboard.layout = "fr";
      output.scale = 1;
    };
  };
}
