{ config, pkgs, ... }:
let
  user = config.system.primaryUser;
  home = "/Users/${user}";
in
{
  system.activationScripts.defaultBrowser.text = ''
    # See available names:
    #   ${pkgs.defaultbrowser}/bin/defaultbrowser -l
    ${pkgs.defaultbrowser}/bin/defaultbrowser "Zen Browser"
  '';

  system.activationScripts.finderFolderViews.text = ''
    echo "configuring Finder folder views..." >&2

    if [ -d "${home}/workflow" ]; then
      find "${home}/workflow" -type d -exec sudo -u ${user} osascript -e '
          on run argv
            tell application "Finder"
              set targetFolder to POSIX file (item 1 of argv) as alias
              open targetFolder
              set current view of Finder window 1 to column view
              close Finder window 1
            end tell
          end run
        ' {} \; >/dev/null
    fi

    if [ -d "${home}/Downloads" ]; then
      sudo -u ${user} osascript -e '
        tell application "Finder"
          set targetFolder to POSIX file "'"${home}/Downloads"'" as alias
          open targetFolder
          set current view of Finder window 1 to list view
          tell list view options of Finder window 1
            set sort column to modification date column
            set sort direction of column modification date column to reversed
          end tell
          close Finder window 1
        end tell
      ' >/dev/null
    fi
  '';

  system.activationScripts.applications.text =
    let
      env = pkgs.buildEnv {
        name = "system-applications";
        paths = config.environment.systemPackages;
        pathsToLink = [ "/Applications" ];
      };
    in
    pkgs.lib.mkForce ''
      echo "setting up /Applications..." >&2
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps

      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
        app_name=$(basename "$src")
        echo "copying $src" >&2
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done
    '';
}
