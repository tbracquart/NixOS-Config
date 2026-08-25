{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./variables.nix
    ./users.nix

    ../../common/system/nix.nix
    ../../common/system/boot.nix
    ../../common/system/networking.nix
    ../../common/system/locale.nix
    ../../common/system/services.nix
    ../../profiles/laptop.nix
    ../../modules/power/options.nix
    ../../modules/power/module.nix

    inputs.noctalia-greeter.nixosModules.default
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
