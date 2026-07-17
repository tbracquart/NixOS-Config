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
      packages = with pkgs; [
        kdePackages.kate 
        kdePackages.kdeconnect-kde
        netflix
        ytmdesktop
      ];
    };
  };
}
