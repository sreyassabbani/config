{ config, pkgs, ... }:
let
  defaultFlake = builtins.readFile ./nushell/templates/default/flake.nix;
  defaultEnvrc = builtins.readFile ./nushell/templates/default/.envrc;
  defaultGitignore = builtins.readFile ./nushell/templates/default/.gitignore;
  defaultAgents = builtins.readFile ./nushell/templates/default/AGENTS.md;
  pythonFlake = builtins.readFile ./nushell/templates/python/flake.nix;
  pythonEnvrc = builtins.readFile ./nushell/templates/python/.envrc;
  pythonGitignore = builtins.readFile ./nushell/templates/python/.gitignore;
  pythonPyproject = builtins.readFile ./nushell/templates/python/pyproject.toml;
  pythonHelix = builtins.readFile ./nushell/templates/python/.helix/languages.toml;
  pythonReadme = builtins.readFile ./nushell/templates/python/README.md;
in
{
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };

    shellAliases = {
      dr = "sudo darwin-rebuild switch --flake ~/nix#${config.home.username}-${pkgs.stdenv.hostPlatform.system}";
    };

    initContent = ''
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

      eval "$(zoxide init --cmd cd zsh)"

      ds() {
        emulate -L zsh
        setopt ERR_EXIT NO_UNSET PIPE_FAIL

        local mode="''${1:-default}"

        case "$mode" in
          default|dev) ;;
          python|py) ;;
          *)
            print -u2 "ds: unsupported template '$mode' (try: ds or ds python)"
            return 1
            ;;
        esac

        case "$mode" in
          default|dev)
            if [[ -e flake.nix ]]; then
              print -u2 "ds: flake.nix already exists here (won't overwrite)."
              return 1
            fi
            ;;
          python|py)
            if [[ -e flake.nix || -e pyproject.toml || -e .helix/languages.toml ]]; then
              print -u2 "ds: project files already exist here (won't overwrite)."
              return 1
            fi
            ;;
        esac

        case "$mode" in
          default|dev)
            cat > flake.nix <<'EOF'
${defaultFlake}EOF
            cat > .envrc <<'EOF'
${defaultEnvrc}EOF
            cat > .gitignore <<'EOF'
${defaultGitignore}EOF
            cat > AGENTS.md <<'EOF'
${defaultAgents}EOF
            ;;
          python|py)
            cat > flake.nix <<'EOF'
${pythonFlake}EOF
            cat > pyproject.toml <<'EOF'
${pythonPyproject}EOF
            cat > README.md <<'EOF'
${pythonReadme}EOF
            mkdir -p .helix
            cat > .helix/languages.toml <<'EOF'
${pythonHelix}EOF
            cat > .envrc <<'EOF'
${pythonEnvrc}EOF
            cat > .gitignore <<'EOF'
${pythonGitignore}EOF
            ;;
        esac

        if (( $+commands[direnv] )); then
          direnv allow
        else
          print -u2 "ds: direnv not found (install it + set up the shell hook)."
          return 1
        fi

        print "ds: $mode ready"
      }

      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey '^x^e' edit-command-line
    '';
  };
}
