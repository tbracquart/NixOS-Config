#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="/etc/nixos-config"

select_existing_host() {
  local hosts=()
  local host

  while IFS= read -r -d "" host; do
    hosts+=("$(basename "$host")")
  done < <(find "$CONFIG_DIR/hosts" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

  if [ "${#hosts[@]}" -eq 0 ]; then
    echo
    echo "Aucune configuration existante n'a été trouvée."
    return
  fi

  echo
  echo "Configurations disponibles :"

  select host in "${hosts[@]}" "Retour"; do
    case "$host" in
      "Retour")
        return
        ;;
      "")
        echo "Choix invalide."
        ;;
      *)
        echo
        echo "Configuration sélectionnée : $host"
        echo "La prochaine étape utilisera cette configuration pour reconstruire la machine."
        read -r -p "Appuyez sur Entrée pour revenir au menu..." _
        return
        ;;
    esac
  done
}

while true; do
  clear

  echo "========================================"
  echo "     NixOS Config Installer"
  echo "========================================"
  echo
  echo "Configuration embarquée : $CONFIG_DIR"
  echo
  echo "Que voulez-vous faire ?"
  echo
  echo "  1) Installer une nouvelle machine"
  echo "  2) Reconstruire une machine existante"
  echo "  3) Quitter"
  echo

  read -r -p "Votre choix [1-3] : " choice

  case "$choice" in
    1)
      echo
      echo "Mode : nouvelle machine"
      echo "La prochaine étape préparera la détection du matériel."
      read -r -p "Appuyez sur Entrée pour revenir au menu..." _
      ;;
    2)
      select_existing_host
      ;;
    3)
      echo
      echo "Au revoir."
      exit 0
      ;;
    *)
      echo
      echo "Choix invalide."
      read -r -p "Appuyez sur Entrée pour réessayer..." _
      ;;
  esac
done
