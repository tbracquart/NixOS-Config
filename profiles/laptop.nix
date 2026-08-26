{ ... }:

{
  imports = [
    ./desktop.nix
    ../modules/virtualisation/module.nix
  ];

  programs.nix-ld.enable = true;
}
