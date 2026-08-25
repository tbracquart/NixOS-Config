{ pkgs, ... }:

{
  users.users.quentin = {
    isNormalUser = true;
    description = "Quentin Bracquart";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [ kdePackages.kate ];
  };
}
