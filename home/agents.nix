{ lib, ... }:
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
      });
}
