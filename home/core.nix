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
    instances.default = {
      launchd.label = "ai.openclaw.gateway";
    };

    # Local gateway mode (default in nix-openclaw, set explicitly for clarity).
    config = {
      agents.defaults = {
        model.primary = "openai-codex/gpt-5.3-codex";
        subagents.model.primary = "openai-codex/gpt-5.3-codex";
      };

      gateway = {
        mode = "local";
      };

      tools.exec.host = "gateway";

      channels.discord = {
        enabled = true;
        # Prefer launchd env fallback for secrets:
        # launchctl setenv DISCORD_BOT_TOKEN "..."
      };
    };

    # Optional:
    # documents = ./openclaw-documents;
    # bundledPlugins.summarize.enable = true;
    # config.providers.anthropic.apiKeyFile = "/Users/sreysus/.secrets/anthropic_api_key";
  };
}
