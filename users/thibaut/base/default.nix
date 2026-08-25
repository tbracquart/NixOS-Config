{ ... }:

{
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  imports = [
    ./00-options.nix
    ./01-packages.nix
    ./02-git.nix
    ./03-fish.nix
    ./04-firefox.nix
    ./05-programs.nix
  ];
}
