{ username, ... }:
let
  secretDir = "/Users/${username}/.secrets";
in
{
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    enableNixpkgsReleaseCheck = false;
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  programs.openclaw = {
    enable = true;
    bundledPlugins.goplaces.config.env = {
      DISCORD_BOT_TOKEN = "${secretDir}/openclaw-discord-bot-token";
      OPENCLAW_GATEWAY_TOKEN = "${secretDir}/openclaw-gateway-token";
    };

    instances.default = {
      launchd.label = "ai.openclaw.gateway";
      config = {
        agents.defaults = {
          model.primary = "openai-codex/gpt-5.3-codex";
          subagents.model.primary = "openai-codex/gpt-5.3-codex";
        };

        # Local gateway mode (default in nix-openclaw, set explicitly for clarity).
        gateway = {
          mode = "local";
          auth.mode = "token";
        };

        tools.exec.host = "gateway";

        channels.discord = {
          enabled = true;
          # Prefer launchd env fallback for secrets:
          # launchctl setenv DISCORD_BOT_TOKEN "..."
        };
      };
    };

    # Optional:
    # documents = ./openclaw-documents;
    # bundledPlugins.summarize.enable = true;
    # config.providers.anthropic.apiKeyFile = "/Users/sreysus/.secrets/anthropic_api_key";
  };
}
