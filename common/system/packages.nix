{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pciutils
    tree
    file
    ripgrep
    cachix
    sops
    ssh-to-age
    usbutils
  ];
}
