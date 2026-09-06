# Installateur nixos-config

Cette ISO est construite à partir du profil minimal officiel de NixOS :

`installer/cd-dvd/installation-cd-minimal.nix`.

Le dépôt de configuration utilisé pour construire l'ISO est également embarqué dans l'image et disponible dans :

`/etc/nixos-config`

Il s'agit d'un instantané de la configuration au moment de la construction de l'ISO.

## Flux prévu

1. démarrer l'ISO ;
2. choisir entre une nouvelle machine et une machine existante ;
3. utiliser la configuration embarquée ;
4. identifier ou générer la configuration matérielle ;
5. préparer explicitement le stockage ;
6. installer la configuration sélectionnée.

## État actuel

L'installateur peut maintenant :

- afficher le choix entre une nouvelle machine et une machine existante ;
- consulter les configurations existantes embarquées dans l'ISO ;
- utiliser les outils nécessaires à la découverte du matériel.

Aucun disque n'est modifié automatiquement.
