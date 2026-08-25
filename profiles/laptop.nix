{ pkgs, ... }:

{
  imports = [
    ./desktop.nix
    ../modules/virtualisation/module.nix
  ];

  environment.systemPackages = with pkgs; [
    mpv
    ripgrep
    dnsmasq
    adw-gtk3
    qt6Packages.qt6ct
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
