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

  # Wiki-link styling; see weft/wikilink/README.md.
  wikilink = pkgs.tree-sitter.buildGrammar {
    language = "wikilink";
    version = "0.1.0";
    src = ./weft/wikilink;
  };
  # Helix's own Markdown queries with the wiki-link additions appended: a
  # query file in the user runtime replaces the bundled one entirely.
  markdownInline =
    file:
    builtins.readFile "${config.programs.helix.package.runtime}/queries/markdown.inline/${file}"
    + builtins.readFile ./weft/wikilink/markdown-inline-${file};

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
      {
        name = "wikilink";
        scope = "source.wikilink";
        injection-regex = "^wikilink$";
        file-types = [ ];
        grammar = "wikilink";
      }
    ];
    language-server.weft.command = "${pkgs.weft}/bin/weft";
  };

  xdg.configFile = {
    "helix/runtime/grammars/wikilink.so".source = "${wikilink}/parser";
    "helix/runtime/queries/wikilink/highlights.scm".source = ./weft/wikilink/queries/highlights.scm;
    "helix/runtime/queries/markdown.inline/highlights.scm".text = markdownInline "highlights.scm";
    "helix/runtime/queries/markdown.inline/injections.scm".text = markdownInline "injections.scm";
  };

  launchd.agents = {
    weft-sync = agent [ ] { StartInterval = 1800; };
    weft-sync-login = agent [ "login" ] { RunAtLoad = true; };
  };
}
