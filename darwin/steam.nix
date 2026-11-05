{ config, pkgs, ... }:
let
  user = config.system.primaryUser;
  home = "/Users/${user}";
  steam = pkgs.callPackage ../pkgs/steam-native.nix { };
  app = "/Applications/Steam.app";
  stamp = "${app}/Contents/.nix-source";
in
{
  # Steam rewrites its own bootstrapper, so /Applications gets a writable copy
  # instead of a store symlink. Swapping the binary breaks Valve's bundle seal;
  # clearing quarantine and ad-hoc signing keeps Gatekeeper from calling it
  # damaged.
  system.activationScripts.postActivation.text = ''
    if [ "$(cat "${stamp}" 2>/dev/null)" != "${steam}" ]; then
      echo "installing native Steam.app..." >&2
      rm -rf "${app}"
      /usr/bin/ditto "${steam}/Applications/Steam.app" "${app}"
      chmod -R u+w "${app}"
      printf '%s' "${steam}" > "${stamp}"
      chown -R ${user}:staff "${app}"
      /usr/bin/xattr -cr "${app}"
      /usr/bin/codesign --force --deep --sign - "${app}" 2>/dev/null
    fi

    # Stay on the beta channel; stable would pull the Intel-only client back.
    sudo -u ${user} mkdir -p "${home}/Library/Application Support/Steam/package"
    sudo -u ${user} sh -c 'printf publicbeta > "$1"' _ \
      "${home}/Library/Application Support/Steam/package/beta"
  '';
}
