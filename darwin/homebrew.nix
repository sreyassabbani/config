{ config, ... }:
{
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = config.system.primaryUser;
    autoMigrate = true;
    trust.formulae = [
      "anomalyco/tap/opencode-v2"
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
      # OneDrive's own updater runs ahead of the cask; a greedy upgrade put the
      # older cask back (Nov 6) and the older app refused the newer sync data.
      {
        name = "onedrive";
        greedy = false;
      }
      "opencode-desktop"
      # "gcloud-cli"
      "blender"
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
      "codex"
      "chatgpt"
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
      brew "anomalyco/tap/opencode-v2", trusted: true
      brew "sreyassabbani/tap/saterminal", trusted: true
      brew "steipete/tap/spogo", trusted: true
    '';

    # Refresh and upgrade Homebrew packages on rebuild, including casks that
    # have their own updater or don't declare a fixed version.
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    greedyCasks = true;
  };
}
