{ self, username }:
{ ... }:
{
  imports = [
    ./activation.nix
    ./defaults.nix
    ./fonts.nix
    ./packages.nix
    ./users.nix
    ./window-manager.nix
  ];

  system.stateVersion = 6;
  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.primaryUser = username;

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  launchd.user.envVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  nixpkgs.config.allowUnfree = true;
}
