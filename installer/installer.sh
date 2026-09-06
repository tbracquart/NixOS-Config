#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="/etc/nixos-config"
WORK_DIR="/tmp/nixos-config-installer"
FACTER_REPORT="$WORK_DIR/facter.json"

pause() {
  echo
  read -r -p "Appuyez sur Entrée pour continuer..." _
}

discover_hardware() {
  mkdir -p "$WORK_DIR"

  clear
  echo "========================================"
  echo "       Découverte du matériel"
  echo "========================================"
  echo
  echo "Cette étape analyse uniquement la machine."
  echo "Aucun disque ne sera modifié."
  echo

  echo "--- Architecture ---"
  uname -m
  echo

  echo "--- Processeur ---"
  lscpu | grep -E "Model name|Architecture" || true
  echo

  echo "--- Stockage détecté ---"
  lsblk -o NAME,SIZE,TYPE,MODEL
  echo

  echo "--- Rapport matériel ---"
  echo "Génération de : $FACTER_REPORT"
  echo

  if nixos-facter -o "$FACTER_REPORT"; then
    echo
    echo "Rapport matériel généré avec succès."
    echo
    echo "Fichier : $FACTER_REPORT"
    echo
    echo "Ce rapport pourra être utilisé lors de la création"
    echo "de la configuration de la nouvelle machine."
  else
    echo
    echo "La génération du rapport matériel a échoué."
    echo "Consultez les messages ci-dessus avant de continuer."
  fi

  pause
}

select_existing_host() {
  local hosts=()
  local host

  while IFS= read -r -d "" host; do
    hosts+=("$(basename "$host")")
  done < <(find "$CONFIG_DIR/hosts" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

  if [ "${#hosts[@]}" -eq 0 ]; then
    echo
    echo "Aucune configuration existante n'a été trouvée."
    pause
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
        pause
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
      discover_hardware
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
      pause
      ;;
  esac
done
