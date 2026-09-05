{ inputs, pkgs, ... }:

{
  my.profile = "laptop";

  my.authentication.howdy.enable = true;
  my.desktop.plasma.enable = true;
  my.flatpak.enable = true;

  environment.systemPackages = [
    (pkgs.writeText "ci-flake-impact-test" (builtins.toString inputs.nix-cachyos-kernel))
  ];
}
