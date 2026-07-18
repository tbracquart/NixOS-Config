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

    fish = {
      enable = true;
      interactiveShellInit = ''
        function rebuild
          sudo nixos-rebuild switch
        end

        function update
          sudo nix-channel --update
        end

        function upgrade
          sudo nixos-rebuild switch --upgrade
        end
      '';
    };
  };
}
