[![Check flake](https://github.com/tbracquart/nixos-config/actions/workflows/check.yml/badge.svg)](https://github.com/tbracquart/nixos-config/actions/workflows/check.yml) [![Check flake](https://github.com/tbracquart/nixos-config/actions/workflows/check.yml/badge.svg)](https://github.com/tbracquart/nixos-config/actions/workflows/update.yml)

# ❄️ nixos-config

Configuration NixOS personnelle, gérée via **Nix Flakes** et **Home Manager**.
Ce dépôt centralise la configuration système et utilisateur de mes machines, avec une base commune partagée et des configurations spécifiques par hôte.

## 🖥️ Hôtes

| Hôte | Description |
|---|---|
| **ZenBook-13** | Poste principal (ASUS ZenBook 13) — NixOS unstable, Hyprland + KDE Plasma 6, Noctalia |
| **V145-15AST** | Lenovo V145-15AST — configuration dédiée, indépendante de la base commune |

## 📁 Structure

```
.
├── common/                     # Configuration partagée (utilisée par ZenBook-13)
│   ├── configuration.nix       # Config système (boot, réseau, sessions graphiques, sécurité...)
│   ├── home.nix                # Config Home Manager (paquets, shell, apps utilisateur)
│   ├── hyprland.lua            # Config Hyprland (syntaxe Lua, chargée hors du store Nix)
│   └── noctalia-settings.toml  # Réglages Noctalia Shell (symlinkés hors du store)
├── hosts/
│   ├── ZenBook-13/
│   │   └── hardware-configuration.nix
│   └── V145-15AST/
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── flake.nix
└── flake.lock
```

## ⚙️ Stack (ZenBook-13)

- **Distribution** : NixOS `nixos-unstable`
- **Bootloader** : Limine
- **Noyau** : CachyOS BORE (via [`nix-cachyos-kernel`](https://github.com/xddxdd/nix-cachyos-kernel))
- **Sessions graphiques** : Hyprland (config Lua) + KDE Plasma 6
- **Shell desktop** : [Noctalia Shell](https://github.com/noctalia-dev) + Noctalia Greeter
- **Shell** : Fish
- **Terminal** : Kitty / Alacritty
- **Auth** : Howdy (reconnaissance faciale, PAM)
- **Gestion des paquets utilisateur** : Home Manager (module NixOS)

### Particularités notables

- Les fichiers de config Hyprland et Noctalia sont liés au dépôt via `mkOutOfStoreSymlink` : toute modification faite depuis l'UI ou en édition directe est donc automatiquement versionnée, sans étape d'export manuelle.
- Firefox est thémé automatiquement en clair/sombre via `xdg-desktop-portal-gtk` + l'extension **Pywalfox**, déclarée nativement en Nix (pas d'installation manuelle, incompatible avec le store en lecture seule).
- Seuil de charge batterie limité à 80 % via un service `systemd` dédié.
- Caches binaires **Cachix** configurés pour éviter la recompilation locale.

## 🚀 Utilisation

### Prérequis

- NixOS avec les flakes activés (`experimental-features = nix-command flakes`)
- Le dépôt cloné dans `~/nixos-config`

### Commandes (alias Fish)

Le dépôt définit plusieurs fonctions Fish pratiques (déclarées dans `home.nix`) :

```fish
rebuild   # nixos-rebuild switch --flake ~/nixos-config#ZenBook-13
update    # nix flake update
upgrade   # update && rebuild
push      # git add/commit/push interactif du dépôt
```

### Build manuel

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#ZenBook-13
# ou
sudo nixos-rebuild switch --flake ~/nixos-config#V145-15AST
```

## ⚠️ Avertissement

Ce dépôt contient du matériel et des identifiants propres à mes machines (UUID LUKS, hostname, utilisateur `thibaut`, etc.). Il n'est **pas conçu comme un template clé en main** — libre à vous de vous en inspirer, mais adaptez `hardware-configuration.nix` et les identifiants à votre propre matériel avant de builder.
