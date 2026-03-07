{ config, pkgs, ... }:
{
  environment.shells = [ pkgs.nushell ];

  users.users.${config.system.primaryUser} = {
    name = config.system.primaryUser;
    home = "/Users/${config.system.primaryUser}";
    shell = pkgs.nushell;
  };
}
