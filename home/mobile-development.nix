{ config, pkgs, ... }:
let
  tools = import ../pkgs/mobile-development.nix { inherit pkgs; };
  sdkPath = "${config.home.homeDirectory}/Library/Android/sdk";
in
{
  home.packages = [ tools.package ];
  home.file."Library/Android/sdk".source = "${tools.sdk}/libexec/android-sdk";
  home.sessionVariables = {
    ANDROID_HOME = sdkPath;
    ANDROID_SDK_ROOT = sdkPath;
    JAVA_HOME = tools.jdk.home;
  };
  home.sessionPath = [
    "${sdkPath}/platform-tools"
    "${sdkPath}/emulator"
    "${sdkPath}/cmdline-tools/latest/bin"
    "${tools.package}/bin"
  ];
  programs.nushell.extraEnv = ''
    $env.ANDROID_HOME = "${sdkPath}"
    $env.ANDROID_SDK_ROOT = "${sdkPath}"
    $env.JAVA_HOME = "${tools.jdk.home}"
    $env.PATH = ($env.PATH | prepend [
      "${sdkPath}/platform-tools"
      "${sdkPath}/emulator"
      "${sdkPath}/cmdline-tools/latest/bin"
      "${tools.package}/bin"
    ])
  '';
}
