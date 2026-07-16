{ config, pkgs, ... }:

{
  # ==========================================
  #  ENVIRONNEMENT & PACKAGES GLOBAUX
  # ==========================================

  nixpkgs.config.allowUnfree = true;

  environment = {
    shells = [ pkgs.fish ];
    systemPackages = with pkgs; [ btop fastfetch pciutils tree kde-rounded-corners file bat mpv ];
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

        function nixpush
          cd /etc/nixos
          sudo git add .
          sudo git status
          read -P "Message de commit : " commit_msg
          sudo git commit -m "$commit_msg"
          sudo git push
        end
      '';
    };

    git = {
      enable = true;
      config = { user.name = "Thibaut Bracquart"; user.email = "thibaut.bracquart@proton.me"; };
    };

  };
}
