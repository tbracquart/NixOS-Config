{ config, pkgs, ... }:

{
  # ==========================================
  #  ENVIRONNEMENT & PACKAGES GLOBAUX
  # ==========================================

  nixpkgs.config.allowUnfree = true;

  environment = {
    shells = [ pkgs.fish ];
    systemPackages = with pkgs; [ htop btop fastfetch pciutils tree kde-rounded-corners file bat mpv ripgrep ];
  };

  # ==========================================
  #  PROGRAMMES
  # ==========================================

  programs = {
    fish = { enable = true; };

    firefox.enable = true;

    kdeconnect = {
      enable = false;
      openFirewall = true;
    };

    vim = { enable = true; defaultEditor = true; };
  };
}
