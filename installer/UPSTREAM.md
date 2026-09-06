# Recette de l'ISO d'installation

## Objectif

Cette ISO doit être dérivée de la recette officielle utilisée par NixOS pour ses images d'installation, puis personnalisée avec les modules propres à ce dépôt.

## Référence upstream

Dans nixpkgs, la construction officielle des ISO est décrite par :

- `nixos/release.nix`, qui expose notamment les jobs `iso_minimal` et `iso_graphical` ;
- les modules `nixos/modules/installer/cd-dvd/*-combined.nix`, utilisés par ces jobs ;
- `iso-image.nix`, qui produit `config.system.build.isoImage`.

Le projet ne doit donc pas réinventer le mécanisme de création de l'image. Les personnalisations doivent être ajoutées par-dessus de cette base upstream.

## À décider avant la prochaine implémentation

- quel profil officiel utiliser comme base exacte ;
- comment intégrer la configuration du dépôt dans l'image ;
- quelle interface utiliser pour l'installation ;
- comment reproduire localement la structure de build officielle sans importer inutilement toute l'infrastructure de release de nixpkgs.
