{ pkgs }:
let
  composition = (pkgs.androidenv.override { licenseAccepted = true; }).composeAndroidPackages {
    cmdLineToolsVersion = "19.0";
    toolsVersion = null;
    platformVersions = [ "36" ];
    buildToolsVersions = [
      "35.0.0"
      "36.0.0"
    ];
    includeNDK = true;
    ndkVersions = [ "27.1.12297006" ];
    includeCmake = true;
    cmakeVersions = [ "3.22.1" ];
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis" ];
    abiVersions = [ "arm64-v8a" ];
    includeSources = false;
  };
  sdk = composition.androidsdk.overrideAttrs (previous: {
    installPhase = previous.installPhase + ''
      ln -s 19.0 "$out/libexec/android-sdk/cmdline-tools/latest"
    '';
  });
  jdk = pkgs.jdk17;
in
{
  inherit jdk;
  inherit sdk;
  package = pkgs.buildEnv {
    name = "mobile-development";
    paths = [
      sdk
      jdk
      pkgs.watchman
    ];
  };
}
