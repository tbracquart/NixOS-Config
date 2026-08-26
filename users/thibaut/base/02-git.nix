{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Thibaut Bracquart";
        email = "202062783+tbracquart@users.noreply.github.com";
      };
      init.defaultBranch = "main";
    };
  };

  programs.gh = {
    enable = true;
    extensions = [ "github-copilot-cli" ];
  };
}
