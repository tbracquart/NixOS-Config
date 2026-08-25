{ ... }:

{
  imports = [
    ./desktop.nix
    ../modules/virtualisation/module.nix
  ];

  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

  programs.nix-ld.enable = true;
}
