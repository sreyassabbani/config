{ pkgs, inputs, ... }:
let
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  saterminalPackage = inputs.saterminal.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
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
    unstablePkgs.codex
    nixfmt-rfc-style
    nixd
    zoxide
    fzf
    saterminalPackage
  ];
}
