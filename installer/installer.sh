#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="/etc/nixos-config"
WORK_DIR="/tmp/nixos-config-installer"
FACTER_REPORT="$WORK_DIR/facter.json"

pause() {
  echo
  read -r -p "Appuyez sur Entrée pour continuer..." _
}

select_target_disk() {
  local disks=()
  local disk

  while IFS= read -r disk; do
    [ -n "$disk" ] && disks+=("$disk")
  done < <(lsblk -dn -o PATH,TYPE | awk '$2 == "disk" { print $1 }')

  if [ "${#disks[@]}" -eq 0 ]; then
    echo
    echo "Aucun disque utilisable n'a été détecté."
    pause
    return 1
  fi

  echo
  echo "Disques détectés :"
  lsblk -d -o PATH,SIZE,MODEL,TRAN
  echo
  echo "Choisissez le disque cible."
  echo "Aucune modification ne sera effectuée à cette étape."
  echo

  select disk in "${disks[@]}" "Retour"; do
    case "$disk" in
      "Retour")
        return 1
        ;;
      "")
        echo "Choix invalide."
        ;;
      *)
        TARGET_DISK="$disk"
        return 0
        ;;
    esac
  done
}

choose_partition_scheme() {
  echo
  echo "Schéma de stockage proposé :"
  echo
  echo "  1) EFI + racine (partitionnement automatique simple)"
  echo "  2) Retour"
  echo

  while true; do
    read -r -p "Votre choix [1-2] : " scheme

    case "$scheme" in
      1)
        PARTITION_SCHEME="efi-root"
        return 0
        ;;
      2)
        return 1
        ;;
      *)
        echo "Choix invalide."
        ;;
    esac
  done
}

preview_partition_plan() {
  clear
  echo "========================================"
  echo "     Plan de partitionnement proposé"
  echo "========================================"
  echo
  echo "Disque cible :"
  echo "  $TARGET_DISK"
  echo
  echo "Schéma : EFI + racine"
  echo
  echo "Le plan suivant sera utilisé ultérieurement :"
  echo
  echo "  1. Table de partitions GPT"
  echo "  2. Partition EFI : 1 GiB"
  echo "     - format : FAT32"
  echo "     - montage : /mnt/boot"
  echo "  3. Partition racine : espace restant"
  echo "     - format : ext4"
  echo "     - montage : /mnt"
  echo
  echo "⚠️  IMPORTANT"
  echo "Ce plan est uniquement affiché."
  echo "Aucune partition n'est créée et aucun disque n'est modifié."
  pause
}

preview_storage_plan() {
  local mode="$1"

  if ! select_target_disk; then
    return
  fi

  clear
  echo "========================================"
  echo "       Plan de stockage"
  echo "========================================"
  echo
  echo "Mode : $mode"
  echo
  echo "Disque sélectionné :"
  echo "  $TARGET_DISK"
  echo
  echo "--- État actuel ---"
  lsblk "$TARGET_DISK" -o NAME,PATH,SIZE,TYPE,FSTYPE,MOUNTPOINTS
  echo

  if choose_partition_scheme; then
    preview_partition_plan
  fi
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
        echo
        echo "========================================"
        echo "        Plan d'installation"
        echo "========================================"
        echo
        echo "Source de la configuration :"
        echo "  $CONFIG_DIR"
        echo
        echo "Configuration NixOS :"
        echo "  #$host"
        echo
        echo "Commande qui sera utilisée après la préparation"
        echo "explicite du stockage :"
        echo
        echo "  nixos-install --flake $CONFIG_DIR#$host"
        echo
        echo "Le stockage n'est pas encore prêt : cette commande"
        echo "n'est donc volontairement pas exécutée."
        preview_storage_plan "Machine existante"
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
      preview_storage_plan "Nouvelle machine"
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
