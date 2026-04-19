{
  lib,
  fetchFromGitHub,
  ffmpeg,
  makeWrapper,
  python3Packages,
}:
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

  dependencies = with python3Packages; [
    click
    tomli
    tomli-w
  ];

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
    wrapProgram "$out/bin/music-cli" \
      --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}"
    wrapProgram "$out/bin/mc" \
      --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}"
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
