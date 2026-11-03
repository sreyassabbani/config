{
  config,
  lib,
  pkgs,
  ...
}:
let
  # The pinned Home Manager predates programs.t3code and its mutable-config
  # helpers. Keep the same merge-on-activation behavior without upgrading it.
  python = pkgs.python3.withPackages (ps: [ ps.json5 ]);
  settings = (pkgs.formats.json { }).generate "t3code-managed-settings.json" {
    "settings.json" = {
      defaultModelSelection = {
        instanceId = "codex";
        model = "gpt-6.1-terra";
        options = [
          {
            id = "reasoningEffort";
            value = "medium";
          }
          {
            id = "serviceTier";
            value = "default";
          }
        ];
      };
      fallbackModelSelection = {
        instanceId = "claudeAgent";
        model = "claude-sonnet-5-5";
      };
      idleCompaction = "onReturn";
    };

    # Existing UI preferences; other preferences remain editable in T3.
    "client-settings.json" = {
      fontFamilyCode = "GeistMono Nerd Font";
      fontSizeCode = 13;
      fontSizeTerminal = 12;
      fontSizeInterface = 16;
      fontSizePrompt = 14;
      chatWidth = "comfortable";
      sidebarProjectGroupingMode = "repository";
      sendShortcut = "enter";
      followUpBehavior = "queue";
      wordWrap = true;
      mathRenderingEnabled = true;
    };
  };
in
{
  home.activation.t3codeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${python}/bin/python3 ${./t3code/merge-settings.py} \
      ${lib.escapeShellArg "${config.home.homeDirectory}/.t3/userdata"} ${settings}
  '';
}
