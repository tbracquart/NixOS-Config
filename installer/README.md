# Installateur nixos-config

Cette ISO est construite à partir du profil minimal officiel de NixOS :

`installer/cd-dvd/installation-cd-minimal.nix`.

Le dépôt de configuration utilisé pour construire l'ISO est également embarqué dans l'image et disponible dans :

`/etc/nixos-config`

Il s'agit d'un instantané de la configuration au moment de la construction de l'ISO.

## Flux prévu

1. démarrer l'ISO ;
2. choisir entre une nouvelle machine et une machine existante ;
3. sélectionner une configuration de base embarquée ;
4. identifier ou générer la configuration matérielle ;
5. préparer une copie de travail de la configuration embarquée pour l'installation ;
5. préparer explicitement le stockage ;
6. installer la configuration sélectionnée.

## État actuel

L'installateur peut maintenant :

- afficher le choix entre une nouvelle machine et une machine existante ;
- générer un rapport matériel avec `nixos-facter` pour une nouvelle machine ;
- enregistrer temporairement le rapport matériel ;
- tenter de générer un module Nix matériel réutilisable pour la configuration sélectionnée ;
- consulter les configurations existantes embarquées dans l'ISO ;
- afficher le plan et la commande d'installation prévue pour une machine existante ;
- détecter et sélectionner explicitement un disque cible sans le modifier ;
- afficher l'état actuel du disque sélectionné avant toute opération destructive ;
- proposer explicitement un schéma de partitionnement ;
- afficher le plan complet avant toute création de partition ;
- demander une confirmation explicite du disque cible avant une future opération destructive.
- utiliser les outils nécessaires à la découverte du matériel.

Le rapport matériel est temporaire : il disparaît au redémarrage de l'environnement live.

La commande finale prévue pour une machine existante est affichée avant toute installation, mais elle n'est pas encore exécutée.

Après confirmation explicite du disque puis du mot `EFFACER`, l'installateur peut créer le schéma GPT + EFI + racine. Le formatage est suivi d'une confirmation explicite avant l'exécution de `nixos-install` avec le host sélectionné.

⚠️ Cette étape supprime les signatures et partitions existantes du disque explicitement confirmé.


## Fin de l'installation

Lorsque `nixos-install` réussit, l'installateur affiche une confirmation claire et propose de redémarrer immédiatement. Le support d'installation doit être retiré avant le redémarrage.


## Test de l'ISO

Avant d'utiliser l'installateur sur une machine réelle, l'ISO doit être testée dans une machine virtuelle.

Le premier test de fumée vérifie notamment :

1. le démarrage de l'image ;
2. la disponibilité du dépôt embarqué ;
3. le lancement du service d'installation ;
4. la disponibilité de `git`, `nix` et `nixos-facter`.

Les tests destructifs de partitionnement et d'installation complète doivent être effectués sur un disque virtuel dédié.
