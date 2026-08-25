{ ... }:

{
  programs.fish = {
    enable = true;
    generateCompletions = false;

    interactiveShellInit = ''
      fish_config theme choose "default-rgb"
      fastfetch
      echo

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

      wait-ci = ''
        if type -q gh
          echo ""
          echo "⏳ Attente du run CI sur $argv[1]..."
          sleep 5
          set -l run_id (gh run list --branch $argv[1] --workflow "NixOS CI" --limit 1 --json databaseId --jq '.[0].databaseId')
          if test -n "$run_id"
            gh run watch $run_id --exit-status
            and echo "✅ CI terminée et poussée vers Cachix."
            or echo "⚠️ CI échouée — un rebuild pourrait compiler en local."
          else
            echo "⚠️ Aucun run CI trouvé."
          end
        else
          echo "ℹ️ gh absent, impossible d'attendre la CI automatiquement."
        end
      '';

      push = ''
        cd ~/nixos-config
        git add .
        git diff --cached
        git status
        read -l -P "Message de commit : " commit_msg
        if test -z "$commit_msg"
          echo "❌ Message de commit vide, annulation."
          return 1
        end
        git commit -m "$commit_msg"
        and begin
          set -l current_branch (git rev-parse --abbrev-ref HEAD)
          read -l -P "Branche de push [$current_branch] : " target_branch
          if test -z "$target_branch"
            set target_branch $current_branch
          end
          git push origin $target_branch
          and wait-ci $target_branch
        end
      '';

      update = ''
        cd ~/nixos-config
        nix flake update
      '';

      rebuild = ''
        sudo nixos-rebuild switch --flake ~/nixos-config#ZenBook-13
      '';

      upgrade = ''
        git -C ~/nixos-config pull --ff-only
        and rebuild
      '';
    };
  };
}
