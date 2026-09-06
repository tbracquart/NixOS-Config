# Installateur nixos-config

Cette ISO est construite à partir du profil minimal officiel de NixOS :

`installer/cd-dvd/installation-cd-minimal.nix`.

Le projet ajoute progressivement une couche d'installation spécifique au dépôt.

## Flux prévu

1. démarrer l'ISO ;
2. récupérer la configuration ;
3. choisir entre une nouvelle machine et une machine existante ;
4. identifier ou générer la configuration matérielle ;
5. préparer explicitement le stockage ;
6. installer la configuration sélectionnée.

## État actuel

Cette étape prépare uniquement les outils nécessaires à la découverte de la configuration et du matériel.

Aucun disque n'est modifié automatiquement.
