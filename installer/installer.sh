#!/usr/bin/env bash
set -euo pipefail
clear
echo "========================================"
echo "     NixOS Config Installer"
echo "========================================"
echo
echo "Que voulez-vous faire ?"
echo
echo "  1) Installer une nouvelle machine"
echo "  2) Reconstruire une machine existante"
echo "  3) Quitter"
echo
read -r -p "Votre choix [1-3] : " choice
case "$choice" in
  1) echo; echo "Mode : nouvelle machine"; echo "La prochaine étape préparera la détection du matériel." ;;
  2) echo; echo "Mode : machine existante"; echo "La prochaine étape permettra de récupérer une configuration existante." ;;
  3) echo; echo "Au revoir."; exit 0 ;;
  *) echo; echo "Choix invalide."; exit 1 ;;
esac
