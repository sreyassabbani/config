{ config, lib, ... }:
let
  # Personally maintained skills. Each is linked live from this repo, so edits
  # apply immediately; adding or removing one needs a rebuild.
  skillsDir = "${config.home.homeDirectory}/config/home/agents/skills";
  skills = builtins.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./agents/skills));
  skillRoots = [
    ".claude/skills"
    ".codex/skills"
  ];
in
{
  home.file =
    lib.genAttrs
      [
        ".codex/AGENTS.md"
        ".claude/CLAUDE.md"
        ".config/opencode/AGENTS.md"
        ".gemini/GEMINI.md"
      ]
      (_: {
        source = ./agents/instructions.md;
      })
    // lib.listToAttrs (
      lib.concatMap (
        root:
        map (name: {
          name = "${root}/${name}";
          value.source = config.lib.file.mkOutOfStoreSymlink "${skillsDir}/${name}";
        }) skills
      ) skillRoots
    );
}
