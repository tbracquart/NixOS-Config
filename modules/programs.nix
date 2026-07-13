{ config, pkgs, ... }:

{
  # ==========================================
  #  ENVIRONNEMENT & PACKAGES GLOBAUX
  # ==========================================

  nixpkgs.config.allowUnfree = true;

  environment = {
    shells = [ pkgs.fish ];
    systemPackages = with pkgs; [
      btop
      fastfetch
      pciutils
      tree
      kde-rounded-corners
      file
      bat
      mpv
      git
    ];
  };

  # ==========================================
  #  PROGRAMMES
  # ==========================================

  programs = {
    firefox.enable = true;

    vim = {
      enable = true;
      defaultEditor = true;
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        fastfetch
        echo

        function clr
          clear
          fastfetch
          echo
        end

        function rebuild
          sudo nixos-rebuild switch
        end
      '';
    };
  };
}
