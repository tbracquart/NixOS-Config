{ config, ... }:

{
  services.xserver.xkb = {
    extraLayouts.global = {
      description = "AZERTY Global";
      languages = [ "fra" ];
      symbolsFile = ./azerty_global;
    };

    layout = "global";
    variant = "";
  };

  console.useXkbConfig = true;

  environment.sessionVariables = {
    XKB_CONFIG_ROOT = config.services.xserver.xkb.dir;
    XKB_DEFAULT_LAYOUT = config.services.xserver.xkb.layout;
    XKB_DEFAULT_VARIANT = config.services.xserver.xkb.variant;
  };
}
