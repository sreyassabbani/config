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

    taps = [
      "steipete/tap"
    ];

    brews = [
      "mas"
      "bat"
      "ffmpeg"
      "spogo"
      "poppler"
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
      "blender"
      "firefox"
      "helium-browser"
      "hammerspoon"
      "notion"
      "microsoft-word"
      "inkscape"
      "obsidian"
      "discord"
      "cursor"
      "microsoft-powerpoint"
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
      "zen"
    ];

    masApps = { };

    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };
}
