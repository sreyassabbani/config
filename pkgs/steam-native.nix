# Steam.app with Valve's universal (arm64 + x86_64) beta bootstrapper, so it
# runs without Rosetta. The installer dmg still ships an Intel-only launcher.
#
# Update the bootstrapper from the `steam_osx` -> `macos-signed-2` entry in
# https://client-update.steamstatic.com/steam_client_publicbeta_osx
{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
  unzip,
}:
let
  bootstrapper = fetchurl {
    url = "https://client-update.steamstatic.com/steam_osx_macos-signed-2.zip.32d0a902dac67005d55955e12a418697ee78559c";
    hash = "sha256-1LoyVI57HOUGwkzjAbksN6XR5aGMRhpNxtTDmnQvrnE=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "steam-native";
  version = "1793740892";

  src = fetchurl {
    url = "https://cdn.cloudflare.steamstatic.com/client/installer/steam.dmg";
    hash = "sha256-4av7qqe+Pg9IoODUwxMjPgWGGx0mrzKDDdyDi+iPJpE=";
  };

  nativeBuildInputs = [
    undmg
    unzip
  ];

  sourceRoot = "Steam.app";
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    unzip -q ${bootstrapper} steam_osx -d "$TMPDIR/bootstrapper"
    install -m755 "$TMPDIR/bootstrapper/steam_osx" Contents/MacOS/steam_osx
    mkdir -p "$out/Applications/Steam.app"
    cp -R . "$out/Applications/Steam.app"
    runHook postInstall
  '';

  meta = {
    description = "Steam client with the native Apple Silicon beta bootstrapper";
    homepage = "https://store.steampowered.com/";
    license = lib.licenses.unfree;
    platforms = [ "aarch64-darwin" ];
  };
}
