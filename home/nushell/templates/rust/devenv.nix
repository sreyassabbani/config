{ pkgs, ... }:
{
  packages = [
    pkgs.bacon
    pkgs.lldb
  ];

  languages.rust.enable = true;
}
