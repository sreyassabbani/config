{ fetchurl, stdenvNoCC }:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pnpm";
  version = "12.7.0";

  src = fetchurl {
    url = "https://github.com/pnpm/pnpm/releases/download/v${finalAttrs.version}/pnpm-darwin-arm64.tar.gz";
    hash = "sha256-gt5ucDf8+qtqHum2Ng6IdyOtaDiXgIEPo+OjVA1giKs=";
  };

  unpackPhase = ''
    tar -xzf "$src" pnpm
  '';

  installPhase = ''
    install -Dm755 pnpm "$out/bin/pnpm"
  '';
})
