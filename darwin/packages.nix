{ pkgs, inputs, ... }:
let
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
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
    unstablePkgs.codex
    nixfmt-rfc-style
    nixd
    zoxide
    fzf
  ];
}
