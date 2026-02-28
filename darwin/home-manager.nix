{ username, openclawHomeManagerModule }:
{ ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit username; };

    users.${username} = { ... }: {
      imports = [
        openclawHomeManagerModule
        ../home
      ];
    };
  };
}
