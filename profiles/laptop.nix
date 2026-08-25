{ pkgs, ... }:

{
  imports = [
    ../modules/desktop/module.nix
    ../modules/virtualisation/module.nix
    ../common/system/security.nix
  ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    htop
    btop
    fastfetch
    pciutils
    tree
    file
    bat
    mpv
    ripgrep
    dnsmasq
    alacritty
    adw-gtk3
    qt6Packages.qt6ct
    cachix
    sops
    ssh-to-age
    usbutils
    nemo-with-extensions
  ];

  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

  programs = {
    fish.enable = true;
    vim = {
      enable = true;
      defaultEditor = true;
    };
    kdeconnect.enable = true;
    nix-ld.enable = true;
  };
}
