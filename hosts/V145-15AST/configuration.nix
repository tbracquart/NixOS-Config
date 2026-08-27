{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./boot.nix

    ../../common
    ../../modules
    ../../profiles/laptop.nix
  ];

  networking.hostName = "V145-15AST";

  my.authentication.howdy.enable = true;
  my.desktop.plasma.enable = true;

  system.stateVersion = "26.05";
}
