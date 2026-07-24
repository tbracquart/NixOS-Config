{ config, pkgs, ... }:

{
  # ==========================================
  #  UTILISATEURS
  # ==========================================

  users = {
    users."thibaut" = {
      isNormalUser = true;
      description = "Thibaut Bracquart";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.fish;
      packages = with pkgs; [ ];
    };
  };
}
