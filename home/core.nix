{ username, ... }:
{
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    enableNixpkgsReleaseCheck = false;
    stateVersion = "25.05";
    sessionVariables = {
      EDITOR = "hx";
    };
  };

  programs.home-manager.enable = true;

  programs.openclaw = {
    enable = true;
    instances.default = { };

    # Local gateway mode (default in nix-openclaw, set explicitly for clarity).
    config = {
      gateway = {
        mode = "local";
      };
    };

    # Optional:
    # documents = ./openclaw-documents;
    # bundledPlugins.summarize.enable = true;
    # config.providers.anthropic.apiKeyFile = "/Users/sreysus/.secrets/anthropic_api_key";
  };
}
