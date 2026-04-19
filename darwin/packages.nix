{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # yabai
    # skhd
    helix
    typst
    mkalias
    gnupg
    pinentry_mac
    fastfetch
    dust
    git
    music-cli
    # spicetify-cli
    ripgrep
    just
    jq
    fritzing
    defaultbrowser
    fd
    nixfmt-rfc-style
    nixd
    zoxide
    fzf
  ];
}
