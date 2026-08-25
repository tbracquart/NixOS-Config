{ config, pkgs, inputs, ... }:

{
  home.packages = (with pkgs; [
    fastfetch
    geany
    netflix
    ytmdesktop
    klavaro
    scrcpy
    vinegar
  ]) ++ [
    inputs.freesmlauncher.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
