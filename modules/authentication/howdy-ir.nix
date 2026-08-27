{ config, lib, ... }:

let
  cfg = config.my.authentication.howdy.ir;
in
{
  options.my.authentication.howdy.ir.enable = lib.mkEnableOption
    "le support infrarouge pour Howdy";

  config = lib.mkIf cfg.enable {
    my.authentication.howdy.enable = true;
    services.linux-enable-ir-emitter.enable = true;
  };
}
