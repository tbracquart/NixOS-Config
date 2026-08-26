{ ... }:

{
  services.howdy = {
    enable = true;
    control = "sufficient";
  };

  # Désactivation de Howdy pour Polkit conservée temporairement pour test.
  # security.pam.services.polkit-1.howdy.enable = false;
}
