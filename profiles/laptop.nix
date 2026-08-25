{ pkgs, ... }:

{
  imports = [
    ./desktop.nix
    ../modules/virtualisation/module.nix
  ];

  environment.systemPackages = with pkgs; [
    mpv
    ripgrep
    adw-gtk3
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
