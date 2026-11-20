{ config, pkgs, ... }:
{
  # Replaces nix-darwin's own `applications` step: Nix apps are linked one by
  # one into /Applications (not a "Nix Apps" folder), so Spotlight and the
  # Dock see them, and a real app already there is left alone.
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

      find ${env}/Applications -maxdepth 1 -type l |
      while read -r app; do
        app_name=$(basename "$app")
        target="/Applications/$app_name"
        src=$(readlink "$app")

        if [ -e "$target" ] && [ ! -L "$target" ] && [ -d "$target" ]; then
          echo "skipping $target; a non-Nix app already exists there" >&2
          continue
        fi

        echo "linking $target" >&2
        rm -rf "$target"
        ln -s "$src" "$target"
      done
    '';
}
