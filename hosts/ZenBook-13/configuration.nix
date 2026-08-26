{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./variables.nix
    ./users.nix
    ./boot.nix

    ../../common/system/nix.nix
    ../../common/system/networking.nix
    ../../common/system/locale.nix
    ../../common/system/keyboard.nix
    ../../common/system/services.nix
    ../../common/system/security.nix
    ../../common/system/shell.nix
    ../../common/system/programs.nix
    ../../common/system/users.nix
    ../../common/system/packages.nix

    ../../modules/location/geoclue2.nix

    ../../profiles/system/laptop.nix
    ../../profiles/system/virtualisation.nix
    ../../profiles/system/hyprland.nix
    ../../profiles/system/howdy-ir.nix
    ../../profiles/system/nix-ld.nix
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  hardware.enableRedistributableFirmware = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  system.stateVersion = "26.05";
}
