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
      merge.conflictstyle = "zdiff3";
      color.ui = "auto";

      alias = {
        sl = "log --oneline";
        st = "status -sb";
        co = "checkout";
        br = "branch";
        ci = "commit";
        lg = "log --oneline --graph --decorate --all";
      };
    };
  };
}
