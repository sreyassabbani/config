{ ... }:
{
  programs.git = {
    enable = true;

    signing = {
      format = "openpgp";
      key = "688241BB0F9A860B";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "Sreyas Sabbani";
        email = "sreyassabbani@gmail.com";
      };

      core = {
        editor = "hx";
        autocrlf = "input";
        pager = "hunk pager";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      fetch.prune = true;
      merge.conflictstyle = "zdiff3";
      color.ui = "auto";

      alias = {
        sl = "log --oneline";
        st = "status -sb";
        co = "checkout";
        br = "branch";
        ci = "commit";
        lg = "log --oneline --graph --decorate --all";
        fetch-switch = "!f() { git fetch && if git rev-parse --verify \"$1\" >/dev/null 2>&1; then git switch \"$1\"; else git switch -c \"$1\" \"origin/$1\"; fi; }; f";
      };
    };
  };
}
