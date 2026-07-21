{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # yabai
    # skhd
    helix
    typst
    tt
    yazi
    mkalias
    gnupg
    pinentry_mac
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
    nixfmt-rfc-style
    nixd
    zoxide
    fzf
  ];
}
