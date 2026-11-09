{ ... }:
{
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  system.defaults = {
    NSGlobalDomain = {
      AppleSpacesSwitchOnActivate = false;
    };

    dock = {
      autohide = true;
      show-recents = false;
      tilesize = 25;
      largesize = 60;
      orientation = "bottom";

      persistent-apps = [
        { app = "/Applications/Anki.app"; }
        { app = "/Applications/Rex Beta.app"; }
        { app = "/Applications/T3 Code (Nightly).app"; }
        { app = "/Applications/Helium.app"; }
        { app = "/Applications/Obsidian.app"; }
        { app = "/Applications/Notion Calendar.app"; }
        { app = "/Applications/Zotero.app"; }
      ];

      persistent-others = [ ];
    };
  };
}
