{
  lib,
  fetchFromGitHub,
  ffmpeg,
  makeWrapper,
  python3,
  python3Packages,
}:
let
  runtimeDeps = with python3Packages; [
    click
    tomli
    tomli-w
  ];
  depPythonPath = lib.makeSearchPath python3.sitePackages runtimeDeps;
in
python3Packages.buildPythonApplication rec {
  pname = "music-cli";
  version = "0.9.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "luongnv89";
    repo = "music-cli";
    rev = "v${version}";
    hash = "sha256-inIGdjXdqloOTuFrBivcHCdBNYQwl3tt6DQZoog6Ar0=";
  };

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  dependencies = runtimeDeps;

  nativeBuildInputs = [
    makeWrapper
  ];

  pythonRemoveDeps = [
    "pyobjc-framework-MediaPlayer"
  ];

  pythonImportsCheck = [
    "music_cli"
  ];

  postFixup = ''
    pythonpath="$out/${python3.sitePackages}"
    if [ -n "${depPythonPath}" ]; then
      pythonpath="$pythonpath:${depPythonPath}"
    fi

    wrapProgram "$out/bin/music-cli" \
      --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}" \
      --prefix PYTHONPATH : "$pythonpath"
    wrapProgram "$out/bin/mc" \
      --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}" \
      --prefix PYTHONPATH : "$pythonpath"
  '';

  meta = with lib; {
    description = "Command-line music player for coders";
    homepage = "https://github.com/luongnv89/music-cli";
    changelog = "https://github.com/luongnv89/music-cli/releases/tag/v${version}";
    license = licenses.mit;
    mainProgram = "music-cli";
    platforms = platforms.unix;
  };
}
