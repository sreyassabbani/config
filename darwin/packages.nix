{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # yabai
    helix
    typst
    tt
    yazi
    mkalias
    gnupg
    pinentry_mac
    git-lfs
    fastfetch
    fast
    btop
    macmon
    dust
    git
    music-cli
    # spicetify-cli
    ripgrep
    repgrep
    fh
    just
    jq
    fritzing
    recordly
    defaultbrowser
    fd
    typescript
    typescript-language-server
    (callPackage ../pkgs/pnpm.nix { })
    nixfmt-rfc-style
    nixd
    zoxide
    fzf
  ];
}
