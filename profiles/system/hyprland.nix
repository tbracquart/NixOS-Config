{ inputs, ... }:

{
  imports = [
    ../../modules/desktop/hyprland.nix
    inputs.noctalia-greeter.nixosModules.default
  ];
}
