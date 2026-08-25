{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    htop
    btop
    pciutils
    tree
    file
    cachix
    sops
    ssh-to-age
    usbutils
    bat
    alacritty
    nemo-with-extensions
  ];
}
