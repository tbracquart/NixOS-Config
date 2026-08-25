{ pkgs, ... }:

{
  imports = [
    ../modules/desktop/module.nix
    ../modules/virtualisation/module.nix
  ];

  environment.systemPackages = with pkgs; [
    htop
    btop
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
    vim = {
      enable = true;
      defaultEditor = true;
    };
    nix-ld.enable = true;
  };
}
