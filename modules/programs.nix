{ config, pkgs, ... }:

{
  # ==========================================
  #  ENVIRONNEMENT & PACKAGES GLOBAUX
  # ==========================================

  nixpkgs.config.allowUnfree = true;

  environment = {
    shells = [ pkgs.fish ];
    systemPackages = with pkgs; [ htop btop fastfetch pciutils tree kde-rounded-corners file bat mpv ];
  };

  # ==========================================
  #  PROGRAMMES
  # ==========================================

  programs = {
    firefox.enable = true;

    vim = { enable = true; defaultEditor = true; };

    kdeconnect.enable = true;

    # Fish activé au niveau système (nécessaire pour users.users.thibaut.shell).
    # Les fonctions perso (rebuild, nixpush, etc.) sont gérées côté
    # Home Manager : voir https://github.com/tbracquart/Home-Manager-Config
    fish.enable = true;

    # Config Git perso (nom, email) migrée vers Home Manager :
    # https://github.com/tbracquart/Home-Manager-Config

    nh.enable = true;
  };
}
