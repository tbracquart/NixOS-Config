{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    htop
    btop
    pciutils
    tree
    file
    ripgrep
    cachix
    sops
    ssh-to-age
    usbutils
    bat
    alacritty
    nemo-with-extensions
  ];
}
