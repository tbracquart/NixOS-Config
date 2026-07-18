# NixOS Config

> 🇫🇷 Version française — [🇬🇧 English version here](./README.en.md)

Ma configuration NixOS personnelle, pensée et affinée pour mon usage quotidien sur mon ZenBook 13.

Ce dépôt n'est pas un template générique ni un tutoriel : c'est **ma** config, construite au fil de mes propres choix, de mes besoins et de mes envies de personnalisation. Je la fais évoluer en continu, un peu comme un projet perso qui ne sera jamais vraiment "fini".

---

## Pourquoi ce projet existe

J'ai migré vers NixOS après être passé par CachyOS, avec l'envie d'avoir un système **entièrement déclaratif et reproductible** : toute ma configuration système est versionnée ici, donc si mon disque lâche ou que je change de machine, je peux reconstruire mon environnement à l'identique en quelques commandes plutôt qu'en réinstallant tout à la main.

Au-delà du côté pratique, c'est aussi un terrain de jeu pour comprendre en profondeur comment fonctionne un système Linux moderne : chiffrement disque, boot, gestion matérielle, sécurité, environnement de bureau.

---

## Matériel

- **Machine** : ASUS ZenBook 13
- **GPU** : Intel Iris Xe (driver `xe`, pas `i915`)
- **Chipset audio** : Intel Tiger Lake (SOF)

---

## Stack technique

| Composant | Choix | Pourquoi |
|---|---|---|
| **Bootloader** | `systemd-boot` | Simple, rapide, natif UEFI |
| **Chiffrement** | LUKS + TPM2 (`systemd-cryptenroll`) | Déverrouillage automatique sécurisé au démarrage |
| **Système de fichiers** | Btrfs avec sous-volumes | Snapshots et flexibilité |
| **Environnement de bureau** | KDE Plasma 6 + SDDM | Interface complète et personnalisable |
| **Shell** | Fish | Plus agréable à utiliser au quotidien que Bash |
| **Authentification** | Howdy (reconnaissance faciale) | Déverrouillage rapide, avec exclusion PAM spécifique pour éviter les conflits avec `polkit` |
| **Theme** | Sweet (thème global KDE) | Choix esthétique personnel |

---

## Structure du dépôt

```
.
├── configuration.nix           # Point d'entrée principal
├── hardware-configuration.nix  # Config matérielle générée par NixOS
└── modules/
    ├── system.nix              # Boot, kernel, GPU, réseau, localisation
    ├── services.nix            # Services système (Plasma, audio, Howdy...)
    ├── users.nix                # Comptes utilisateurs
    └── programs.nix            # Programmes, shell Fish, Git
```

Ma configuration **Home Manager** (packages et dotfiles utilisateur) vit dans un dépôt séparé : **[Home-Manager-Config](https://github.com/tbracquart/Home-Manager-Config)**. Séparation volontaire, pour garder une frontière nette entre config système (`root`) et config utilisateur (`thibaut`).

Chaque module est responsable d'un domaine précis, pour que ce soit facile à faire évoluer sans tout casser.

---

## Quelques problèmes résolus au passage

- **Boot qui prenait 3 minutes** à cause d'un point-virgule mal placé dans un UUID LUKS
- **Conflit Howdy / polkit** résolu via une exclusion PAM spécifique
- **Bug audio connu sur Tiger Lake + SOF** après une veille, avec solution de contournement documentée en commentaire

---

## Note

Cette configuration est en perpétuelle évolution, au rythme de mes découvertes et de mes envies de personnalisation.
