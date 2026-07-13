{ config, pkgs, ... }:

{
  # ==========================================
  #  UTILISATEURS
  # ==========================================

  users = {
    users."thibaut" = {
      isNormalUser = true;
      description = "Thibaut Bracquart";
      extraGroups = [ "networkmanager" "wheel" "sudo" ];
      shell = pkgs.fish;
      home = "/home/thibaut";
      packages = with pkgs; [
        kdePackages.kate 
        kdePackages.kdeconnect-kde
        netflix
      ];
    };
  };
}
