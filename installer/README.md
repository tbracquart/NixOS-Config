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
5. préparer explicitement le stockage ;
6. installer la configuration sélectionnée.

## État actuel

L'installateur peut maintenant :

- afficher le choix entre une nouvelle machine et une machine existante ;
- générer un rapport matériel avec `nixos-facter` pour une nouvelle machine ;
- enregistrer temporairement ce rapport dans `/tmp/nixos-config-installer/facter.json` ;
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
