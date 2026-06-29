{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    profiles.default = {
      userSettings = {
        "editor.formatOnSave" = true;
        "workbench.colorTheme" = "Catppuccin Frappé";
        "workbench.iconTheme" = "catppuccin-frappe";
        "git.autofetch" = true;
        "editor.fontFamily" = "JetBrainsMono Nerd Font";
        "editor.fontLigatures" = true;
        "manim-sideview.defaultManimPath" = "/Users/sreysus/workflow/egregium/playground/.venv/bin/manim";
      };

      extensions = with pkgs.vscode-marketplace; [
        openai.chatgpt
        jnoortheen.nix-ide
        jdinhlife.gruvbox
        tal7aouy.icons
        astro-build.astro-vscode
        # not sure how to enable vscode extensions per project
        esbenp.prettier-vscode
        platformio.platformio-ide
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
        rust-lang.rust-analyzer
        ms-python.python
      ];
    };
  };
}
