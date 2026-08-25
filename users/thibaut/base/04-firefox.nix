{ pkgs, inputs, ... }:

{
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ pkgs.pywalfox-native ];
    profiles.thibaut = {
      id = 0;
      isDefault = true;
      path = "2jto0bxf.default";
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        pywalfox
      ];
    };
  };
}
