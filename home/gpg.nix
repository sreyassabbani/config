{ pkgs, ... }:
{
  programs.gpg = {
    enable = true;
    package = pkgs.gnupg;
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };
}
