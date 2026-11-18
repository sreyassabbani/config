{ pkgs, ... }:
{
  languages.rust.enable = true;

  packages = [
    pkgs.bacon
    pkgs.llvmPackages_21.lldb # same LLDB as `cpp`
  ];
}
