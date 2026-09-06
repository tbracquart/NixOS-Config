{ pkgs, ... }:
{
  systemd.services.nixos-config-installer = {
    description = "NixOS Config Installer";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "tty";
      TTYPath = "/dev/tty1";
      TTYReset = true;
      TTYVHangup = true;
    };
    script = ''
      exec ${pkgs.bash}/bin/bash ${./installer.sh}
    '';
  };
}
