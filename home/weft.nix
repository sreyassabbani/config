{
  config,
  lib,
  pkgs,
  ...
}:
let
  home = config.home.homeDirectory;
  vault = "${home}/workflow/thoughts";
  log = "${home}/Library/Logs/weft-sync.log";
  # The last day whose change lists are written.
  listed = "${config.xdg.stateHome}/weft-sync/listed-through";

  # Vault sync, replacing obsidian-git and obsidian-list-modified; see
  # weft/sync.nu.
  sync = pkgs.writers.writeNuBin "weft-sync" {
    makeWrapperArgs = [
      # git and gpg come from Nix; ssh is left to /usr/bin, whose UseKeychain
      # unlocks the GitHub key from launchd.
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath [
        pkgs.git
        pkgs.weft
      ])
      "--set"
      "WEFT_VAULT"
      vault
      "--set"
      "WEFT_LISTED"
      listed
    ];
  } (builtins.readFile ./weft/sync.nu);

  # `weft` on PATH: `weft sync` runs the sync above, anything else goes to
  # weft itself. Sync stays here rather than in weft because it is this
  # machine's git policy, not something a public tool should carry.
  cli = pkgs.writeShellApplication {
    name = "weft";
    text = ''
      if [ "''${1:-}" = sync ]; then
        shift
        exec ${sync}/bin/weft-sync "$@"
      fi
      exec ${pkgs.weft}/bin/weft "$@"
    '';
  };

  agent = args: extra: {
    enable = true;
    config = {
      ProgramArguments = [ "${sync}/bin/weft-sync" ] ++ args;
      StandardOutPath = log;
      StandardErrorPath = log;
    }
    // extra;
  };
in
{
  # weft, the language server for the notes in ~/workflow/thoughts, and the
  # sync that replaced obsidian-git. Source: ~/workflow/weft.
  home.packages = [ cli ];

  programs.helix.languages = {
    language = [
      {
        name = "markdown";
        roots = [
          ".weft"
          ".obsidian"
          ".git"
        ];
        "language-servers" = [ "weft" ];
      }
    ];
    language-server.weft.command = "${pkgs.weft}/bin/weft";
  };

  launchd.agents = {
    weft-sync = agent [ ] { StartInterval = 1800; };
    weft-sync-login = agent [ "login" ] { RunAtLoad = true; };
  };
}
