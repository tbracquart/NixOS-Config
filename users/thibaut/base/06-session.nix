{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "vim";
    NIXCFG = "~/nixos-config";
  };

  systemd.user.services.hyprland-power-inhibit = {
    Unit = {
      Description = "Inhibit logind power key handling for Hyprland session";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=handle-power-key --who=Hyprland --why=\"Noctalia power menu\" --mode=block sleep infinity";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
