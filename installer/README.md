# Fondations de l'installateur

Cette ISO sert de point de départ à un installateur personnalisé pour cette configuration NixOS.

## Principe

L'installateur ne dépend pas d'un installateur graphique généraliste. Il s'appuiera progressivement sur les outils natifs de NixOS.

Le futur flux visé est :

1. démarrer l'ISO ;
2. récupérer le dépôt de configuration ;
3. choisir entre une nouvelle machine et une machine existante ;
4. préparer le stockage ;
5. générer ou récupérer la configuration matérielle ;
6. installer la configuration NixOS sélectionnée.

## État actuel

Cette première étape ne modifie pas encore automatiquement les disques. Elle ajoute uniquement les outils nécessaires pour construire progressivement ce flux.

⚠️ Toute future étape de partitionnement ou d'installation devra demander une confirmation explicite avant de détruire des données.
