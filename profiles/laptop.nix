{ pkgs, ... }:

{
  imports = [
    ./desktop.nix
    ../modules/virtualisation/module.nix
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
