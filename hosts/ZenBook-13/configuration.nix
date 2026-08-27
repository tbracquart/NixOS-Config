{
  pkgs,
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

  networking.hostName = "ZenBook-13";

  my.authentication.howdy.ir.enable = true;
  my.compatibility.nix-ld.enable = true;
  my.desktop.hyprland.enable = true;
  my.location.geoclue2.enable = true;
  my.power.batteryChargeLimit = 80;
  my.virtualisation.libvirt.enable = true;

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
