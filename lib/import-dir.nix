# Import every `*.nix` file in a directory except `default.nix`, so adding a
# module is just adding a file.
dir:
let
  entries = builtins.readDir dir;
  isModule =
    name:
    name != "default.nix" && entries.${name} == "regular" && builtins.match ".*\\.nix" name != null;
in
{
  imports = map (name: dir + "/${name}") (builtins.filter isModule (builtins.attrNames entries));
}
