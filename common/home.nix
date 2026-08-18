{ config, pkgs, inputs, ... }:

{
  # --- INFORMATIONS UTILISATEUR & ÉTAT ---
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  home.enableNixpkgsReleaseCheck = false;

  systemd.user.services.hyprland-power-inhibit = {
    Unit = {
      Description = "Inhibit logind power key handling for Hyprland session";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=handle-power-key --who=Hyprland --why=\"Noctalia power menu\" --mode=block sleep infinity";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # --- VARIABLES D'ENVIRONNEMENT ---
  home.sessionVariables = {
    EDITOR = "vim";
    NIXFLK = "/etc/nixos";
    NIXCFG = "/etc/nixos/common";
  };

  # --- PAQUETS UTILISATEUR ---
  home.packages = (with pkgs; [
    kdePackages.kate
    kdePackages.kdeconnect-kde
    netflix
    ytmdesktop
    klavaro
    scrcpy
    vinegar
    noctalia
  ]) ++ [ inputs.freesmlauncher.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  # --- SERVICES UTILISATEUR ---

  # --- APPLICATIONS & CONFIGURATIONS ---

  # 1. Git
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Thibaut Bracquart";
        email = "202062783+tbracquart@users.noreply.github.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };

  programs.gh = {
    enable = true;
    extensions = with pkgs; [
      github-copilot-cli
    ];
  };

  # 2. Terminal Kitty
  programs.kitty.enable = true;

  # 3. Shell Fish
  programs.fish = {
    enable = true;
    generateCompletions = false;
    interactiveShellInit = ''
      fastfetch
      echo

      # Charge le token Cachix (écriture) depuis un fichier hors dépôt Git,
      # pour ne jamais committer de secret dans le repo public.
      if test -f ~/.config/cachix/token.fish
        source ~/.config/cachix/token.fish
      end
    '';

    functions = {
      clr = ''
        clear
        fastfetch
        echo
      '';

      push = ''
        cd ~/nixos-config
        git add .
        git diff --cached
        git status
        read -l -P "Message de commit : " commit_msg

        if test -z "$commit_msg"
          echo "❌ Message de commit vide, annulation (rien commité, rien poussé)."
          return 1
        end

        git commit -m "$commit_msg"
        and git push
        and echo "✅ Push terminé !"
        or echo "❌ Commit ou push échoué, arrêt (rien poussé)."
      '';

      update = ''
        echo "🔄 Mise à jour des Flakes..."
        cd ~/nixos-config
        nix flake update
        and echo "✅ Flakes à jour !"
        or echo "❌ Mise à jour des flakes échouée."
      '';

      rebuild = ''
        echo "🚀 Reconstruction du système NixOS + Home Manager..."
        sudo nixos-rebuild switch --flake ~/nixos-config#ZenBook-13
        and begin
          echo "✅ Fini !"

          # Alimente le cache Cachix perso avec le résultat construit
          # localement, indépendamment du CI (qui ne tourne que sur push).
          if type -q cachix; and set -q CACHIX_AUTH_TOKEN
            echo "📦 Envoi vers le cache tbracquart..."
            nix path-info --derivation /run/current-system | cachix push tbracquart
            or echo "⚠️  Push Cachix échoué (non bloquant)."
          else
            echo "ℹ️  cachix ou CACHIX_AUTH_TOKEN absent, pas de push vers le cache."
          end

          cd ~/nixos-config
          if test -z (git status --porcelain)
            echo "ℹ️  Rien à commit, pas de push."
          else
            push
          end
        end
        or echo "❌ Rebuild échoué, pas de push."
      '';

      upgrade = ''
        echo "🌟 Mise à jour complète du système 🌟"
        update
        and rebuild
        and echo "🎉 Terminé !"
        or echo "❌ Upgrade interrompu."
      '';
    };
  };

  # 3bis. Firefox — extension Pywalfox pour suivre le thème Noctalia.
  # Le paquet pywalfox-native est déclaré ici (pas via un "pywalfox start" à
  # la main) car nativeMessagingHosts.packages est le mécanisme officiel
  # Home Manager qui écrit le manifeste JSON au bon endroit
  # (~/.mozilla/native-messaging-hosts/) sans toucher au store Nix — la
  # commande `pywalfox install` casse sur NixOS car elle essaie de chmod un
  # fichier dans le store, qui est en lecture seule.
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ pkgs.pywalfox-native ];
    profiles.thibaut = {
      id = 0;
      isDefault = true;
      path = "2jto0bxf.default";
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        pywalfox
      ];
    };
  };

  # 4. Noctalia Shell — le fichier réellement écrit par l'UI (settings.toml dans
  # ~/.local/state/) est symlinké hors du store, directement vers le repo. Chaque
  # réglage fait depuis l'UI Noctalia est donc automatiquement versionné, sans
  # étape manuelle (`noctalia config export`) à répéter.
  home.file.".local/state/noctalia/settings.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "/home/thibaut/nixos-config/common/noctalia-settings.toml";

  # 5. Compositeur Hyprland (Config Lua)
  # Même logique que le settings.toml de Noctalia plus haut : le fichier .lua
  # est un mkOutOfStoreSymlink vers le repo, pas une copie figée dans le
  # store. Toute édition de hyprland.lua est donc reprise par Hyprland au
  # simple rechargement de la config (hyprctl reload), sans passer par un
  # nixos-rebuild switch complet.
  #
  # Note : extraLuaFiles.<name>.content copie le CONTENU dans le store (donc
  # figé, pas de rechargement à chaud) même si on lui passe un
  # mkOutOfStoreSymlink en valeur. Pour un vrai symlink hors-store, il faut
  # passer par home.file directement, puis charger le fichier avec un
  # require() explicite dans extraConfig.
  home.file.".config/hypr/init.lua".source =
    config.lib.file.mkOutOfStoreSymlink
      "/home/thibaut/nixos-config/common/hyprland.lua";

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    systemd.enable = true;

    extraConfig = ''require("init")'';
  };
}
