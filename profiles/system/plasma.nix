{ ... }:

{
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "global";
    variant = "";
  };
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
}
