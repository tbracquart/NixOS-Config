{ ... }:

{
  imports = [
    ./howdy.nix
  ];

  services.linux-enable-ir-emitter.enable = true;
}
