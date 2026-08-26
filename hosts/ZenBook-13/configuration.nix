{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
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
    ../../common/users/thibaut.nix
    ../../common/system/packages.nix

    ../../modules/location/geoclue2.nix
    ../../modules/virtualisation/module.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/authentication/howdy-ir.nix
    ../../modules/compatibility/nix-ld.nix

    ../../profiles/laptop.nix
  ];

  networking.hostName = "ZenBook-13";
  my.power.batteryChargeLimit = 80;

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
