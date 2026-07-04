{
  lib,
  stdenv,
  bun,
  fetchurl,
  makeWrapper,
}:
let
  version = "0.3.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/saterminal/-/saterminal-${version}.tgz";
    hash = "sha512-7vm01jjXni/4coLujjT6w3Ni050Irzf+mv3Fwt/VDo82/sgM2s74cJZ9ZSGm0Nc78EyLSdJV9Oy/GNM6NA8Ipg==";
  };

  nodeModules = stdenv.mkDerivation {
    pname = "saterminal-node_modules";
    inherit version src;

    sourceRoot = "package";

    nativeBuildInputs = [ bun ];

    dontConfigure = true;
    dontCheckForBrokenSymlinks = true;

    buildPhase = ''
      bun install --no-progress --frozen-lockfile
      rm -rf node_modules/.cache
    '';

    installPhase = ''
      mkdir -p $out/node_modules
      cp -R node_modules/. $out/node_modules/
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-r9fQVTd+Jkq+m8QWCNOsFSn5Iotou/l0ROGkzz/MoLc=";
  };
in
stdenv.mkDerivation {
  pname = "saterminal";
  inherit version src;

  sourceRoot = "package";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bun ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    appDir="$out/lib/saterminal"
    mkdir -p "$appDir" "$out/bin"
    cp -R . "$appDir/"
    ln -s ${nodeModules}/node_modules "$appDir/node_modules"

    makeWrapper ${bun}/bin/bun "$out/bin/sat" \
      --add-flags "run" \
      --add-flags "$appDir/src/main.ts"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Terminal UI for Sats Terminal";
    homepage = "https://www.npmjs.com/package/saterminal";
    license = licenses.mit;
    mainProgram = "sat";
    platforms = platforms.unix;
  };
}
