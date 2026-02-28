{ username, openclawHomeManagerModule }:
{ ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit username; };

    users.${username} = { ... }: {
      imports = [
        openclawHomeManagerModule
        ../home
      ];
    };
  };
}
