{ config, pkgs, inputs, ... }:

{
  home.packages = (with pkgs; [
    alacritty
    btop
    firefox
    geany
    netflix
    ytmdesktop
    klavaro
    scrcpy
    vinegar
    nemo-with-extensions
  ]) ++ [
    inputs.freesmlauncher.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
