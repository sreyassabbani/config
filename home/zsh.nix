{ config, lib, pkgs, ... }:
{
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };

    # Agent shells (Claude Code, Codex) replay zsh functions, including
    # zoxide's `cd`, without the chpwd hooks, so zoxide's doctor fires on every
    # `cd`. Keep the check for real terminals only.
    envExtra = ''
      [[ -o interactive ]] || export _ZO_DOCTOR=0

      # GUI agents may inherit a PATH without user or Homebrew tools. Append them
      # so an existing project dev shell still takes precedence.
      typeset -U path
      path+=(${lib.escapeShellArg "${config.home.homeDirectory}/.local/bin"} ${lib.escapeShellArg "${config.home.homeDirectory}/.t3/bin"} /opt/homebrew/bin /opt/homebrew/sbin)
    '';

    shellAliases = {
      dr ="sudo darwin-rebuild switch --flake ~/config#${config.home.username}-${pkgs.stdenv.hostPlatform.system}";
    };

    initContent = lib.mkMerge [
    ''
      setopt PROMPT_SUBST

      function update_prompt() {
        PROMPT=$'\n'

        if [[ $PWD != $HOME ]]; then
          PROMPT+="%F{#737994}%~%f"$'\n'
        fi

        PROMPT+="%F{#8caaee}%n%f %F{#f4b8e4}[λ]%f "
      }

      PS2="%F{#737994} [...]%f "

      autoload -U add-zsh-hook
      add-zsh-hook chpwd update_prompt
      update_prompt

      RPROMPT='%F{$CTP_OVERLAY0}$(git rev-parse --is-inside-work-tree 2>/dev/null && echo "git:") %F{$CTP_SURFACE2}$(git rev-parse --abbrev-ref HEAD 2>/dev/null)%f'

      ZSH_THEME_GIT_PROMPT_PREFIX="%F{$CTP_OVERLAY0}[git:"
      ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
      ZSH_THEME_GIT_PROMPT_DIRTY="%F{$CTP_OVERLAY0}] ✖ %f"
      ZSH_THEME_GIT_PROMPT_CLEAN="%F{$CTP_OVERLAY0}] ✔%f"

      # One `ds` implementation: the Nushell one in `nushell/ds.nu`.
      ds() {
        nu -c "source '${./nushell/ds.nu}'; ds $*"
      }

      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey '^x^e' edit-command-line
    ''

    # Run after other shell integrations so zoxide's hook remains last.
    (lib.mkOrder 2000 ''
      eval "$(zoxide init --cmd cd zsh)"
    '')
    ];
  };
}
