{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "fast";
  version = "0-unstable-2026-07-01";

  src = fetchFromGitHub {
    owner = "maaslalani";
    repo = "fast";
    rev = "26d8fc9c189ba748c68f8930af11dee5c2467f7e";
    hash = "sha256-YeDx082+ySqzamo9UutFTXXkrb37nmqt3ZUNzUHShf4=";
  };

  vendorHash = "sha256-YSjJ8NOL97hXZLnfGYIjoKmARv+gWOsv+5qkl9konnA=";

  postPatch = ''
    substituteInPlace go.mod \
      --replace-fail "go 1.26.3" "go 1.26.2"
  '';

  meta = {
    description = "Test your download and upload speed from the terminal";
    homepage = "https://github.com/maaslalani/fast";
    license = lib.licenses.mit;
    mainProgram = "fast";
    platforms = lib.platforms.unix;
  };
}
