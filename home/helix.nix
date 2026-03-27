{ config, pkgs, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "catppuccin_frappe";

      editor = {
        "line-number" = "relative";
        bufferline = "multiple";
        cursorline = true;
        mouse = false;
        rulers = [ 120 ];
        "true-color" = true;
        "end-of-line-diagnostics" = "hint";

        "soft-wrap".enable = true;

        "inline-diagnostics" = {
          "cursor-line" = "error";
          "other-lines" = "disable";
        };

        "cursor-shape" = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        "indent-guides" = {
          character = "╎";
          render = true;
        };

        "file-picker".hidden = false;

        statusline.left = [
          "mode"
          "spinner"
          "version-control"
          "file-name"
        ];
      };

      keys = {
        normal = {
          ret = "goto_word";

          space = {
            I = ''@mi":run-shell-command typst-figure "%{selection}"<ret>'';
            i = ":toggle lsp.display-inlay-hints";
            x = ":buffer-close";
            q = ":q!";
            "/" = "toggle_comments";
            ";" = "global_search";
            b = ":new";
            l = "select_all";
            z = ":toggle soft-wrap.enable";
            o = "file_picker_in_current_buffer_directory";
          };

          X = "select_line_above";
          G = "goto_file_end";
          tab = ":buffer-next";
          "S-tab" = ":buffer-previous";

          "A-j" = [
            "extend_to_line_bounds"
            "delete_selection"
            "paste_after"
          ];

          "A-k" = [
            "extend_to_line_bounds"
            "delete_selection"
            "move_line_up"
            "paste_before"
          ];

          "*" = [
            "move_prev_word_start"
            "move_next_word_end"
            "search_selection"
            "search_next"
          ];

          "#" = [
            "move_prev_word_start"
            "move_next_word_end"
            "search_selection"
            "search_prev"
          ];
        };

        select = {
          X = "select_line_above";
          space."/" = "toggle_comments";
        };
      };
    };

    languages = {
      editor."auto-format" = true;

      language = [
        {
          name = "typst";
          formatter.command = "typstyle";
          "auto-format" = true;
        }

        {
          name = "python";
          "language-servers" = [
            "basedpyright"
            "ruff"
          ];
          formatter = {
            command = "ruff";
            args = [
              "format"
              "-"
            ];
          };
          "auto-format" = true;
        }

        {
          name = "c";
          "file-types" = [ "c" ];
          indent = {
            "tab-width" = 4;
            unit = "  ";
          };
        }

        {
          name = "json";
          indent = {
            "tab-width" = 4;
            unit = "  ";
          };
        }

        {
          name = "typescript";
          "auto-format" = true;
        }

        {
          name = "latex";
          "file-types" = [ "tex" ];
          "language-servers" = [ "texlab" ];
        }

        {
          name = "scss";
          "file-types" = [ "scss" ];
          grammar = "scss";
        }

        {
          name = "cpp";
          scope = "source.cpp";
          roots = [
            ".clangd"
            "compile_commands.json"
            ".git"
          ];
          "file-types" = [
            "cpp"
            "h"
            "c"
            "hpp"
          ];
          "language-servers" = [ "clangd" ];
          formatter = {
            command = "clang-format";
            args = [ "--style=file" ];
          };
          "auto-format" = true;
          indent = {
            "tab-width" = 4;
            unit = "    ";
          };
        }

        {
          name = "nix";
          "file-types" = [ "nix" ];
          roots = [
            "flake.nix"
            "shell.nix"
            "default.nix"
          ];
          "language-servers" = [ "nixd" ];
          formatter = {
            command = "nixfmt";
          };
          "auto-format" = true;
        }
      ];

      "language-server" = {
        basedpyright = {
          command = "basedpyright-langserver";
          args = [ "--stdio" ];
        };

        ruff = {
          command = "ruff";
          args = [ "server" ];
        };

        nixd = {
          command = "nixd";
        };
      };
    };
  };
}
