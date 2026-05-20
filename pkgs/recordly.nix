{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
let
  version = "1.2.1";
  sources = {
    aarch64-darwin = {
      arch = "arm64";
      hash = "sha256-0Mk+ha3n2RA9LtwdoCele82666a4NCLylMruTFGS7C4=";
    };
    x86_64-darwin = {
      arch = "x64";
      hash = "sha256-PRG1DOX9sy9AJCC1/haEWlcNGkBiO9zicf9ng6Ix8fw=";
    };
  };
  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Recordly is only packaged here for macOS systems");
in
stdenvNoCC.mkDerivation {
  pname = "recordly";
  inherit version;

  src = fetchurl {
    url = "https://github.com/webadderallorg/Recordly/releases/download/v${version}/Recordly-${source.arch}.zip";
    hash = source.hash;
  };

  nativeBuildInputs = [
    unzip
  ];

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  unpackPhase = ''
    runHook preUnpack
    unzip -q "$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -R Recordly.app "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "Screen recorder and editor for polished product demos";
    homepage = "https://github.com/webadderallorg/Recordly";
    changelog = "https://github.com/webadderallorg/Recordly/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
