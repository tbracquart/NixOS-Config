{ config, pkgs, inputs, ... }:

{
  home.packages = (with pkgs; [
    kdePackages.kate
    netflix
    ytmdesktop
    klavaro
    scrcpy
    vinegar
  ]) ++ [
    inputs.freesmlauncher.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
