{ config, ... }:
{
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = config.system.primaryUser;
    autoMigrate = true;
    trust.formulae = [
      "anomalyco/tap/opencode"
      "sreyassabbani/tap/saterminal"
      "steipete/tap/spogo"
    ];
  };

  homebrew = {
    enable = true;

    # Prefer Homebrew for fast-moving, self-updating macOS apps and CLIs. Nix
    # remains the owner of reproducible system and development dependencies.

    taps = [
      "modem-dev/tap"
      "sreyassabbani/tap"
      "steipete/tap"
      "anomalyco/tap"
    ];

    brews = [
      "ghostscript"
      "mas"
      "bun"
      "bat"
      "ffmpeg"
      "poppler"
      "gh"
      "tldr"
      "gemini-cli"
      "tcl-tk"
      "python"
      "go"
      "tree"
      "googleworkspace-cli"
      "hunk"
    ];

    casks = [
      "onedrive"
      "opencode-desktop"
      # "gcloud-cli"
      # "blender"
      # "firefox"
      "helium-browser"
      "hammerspoon"
      "notion"
      "microsoft-word"
      # "inkscape"
      "obsidian"
      "discord"
      "cursor"
      "microsoft-powerpoint"
      # "zoom"
      "skim"
      "slack"
      "ghostty"
      "iina"
      "google-drive"
      "zotero"
      "spotify"
      "notion-calendar"
      "anki"
      "antigravity"
      "visual-studio-code"
      "codex"
      {
        name = "chatgpt";
        greedy = true;
      }
      "the-unarchiver"
      # "zen"
    ];

    masApps = { };

    # The pinned nix-darwin emits --cleanup, which Homebrew 7 no longer accepts.
    # Keep the same uninstall behavior with Homebrew's supported flag.
    onActivation.cleanup = "none";
    onActivation.extraFlags = [ "--force-cleanup" ];

    # Keep trust entries in the Brewfile so --force-cleanup preserves them.
    extraConfig = ''
      brew "anomalyco/tap/opencode", trusted: true
      brew "sreyassabbani/tap/saterminal", trusted: true
      brew "steipete/tap/spogo", trusted: true
    '';

    # Keep system activation idempotent and independent of vendor download
    # availability. Upgrade Homebrew packages explicitly instead.
    onActivation.autoUpdate = false;
    onActivation.upgrade = false;
  };
}
