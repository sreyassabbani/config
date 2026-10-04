{
  lib,
  buildGoModule,
  installShellFiles,
  source,
}:

buildGoModule {
  pname = "tt";
  version = "0.4.2-truecolor";
  src = lib.cleanSource source;
  vendorHash = "sha256-9V5mq7ft30yQ5mBDspXwQBj8l1x+P6UeNr1e5YEaC/c=";
  subPackages = [ "src" ];
  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    mv "$out/bin/src" "$out/bin/tt"
    installManPage tt.1.gz
  '';

  meta = {
    description = "Terminal typing test with current truecolor rendering";
    homepage = "https://github.com/lemnos/tt";
    license = lib.licenses.mit;
    mainProgram = "tt";
    platforms = lib.platforms.unix;
  };
}
