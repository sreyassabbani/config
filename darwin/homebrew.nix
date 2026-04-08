{ config, ... }:
{
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = config.system.primaryUser;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;

    brews = [
      "mas"
      "bat"
      "ffmpeg"
      "gh"
      "tldr"
      "gemini-cli"
      "tcl-tk"
      "python"
      "go"
      "tree"
      "googleworkspace-cli"
    ];

    casks = [
      "gcloud-cli"
      "firefox"
      "hammerspoon"
      "notion"
      "microsoft-word"
      "inkscape"
      "obsidian"
      "codex"
      "discord"
      "cursor"
      "microsoft-powerpoint"
      "microsoft-word"
      "zoom"
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
      "chatgpt-atlas"
      "the-unarchiver"
      "zen-browser"
    ];

    masApps = { };

    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };
}
