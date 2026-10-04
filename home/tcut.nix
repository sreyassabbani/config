{ config, pkgs, ... }:
let
  # Build tcut with a supported Bun without replacing Bun used by other projects.
  bunArchive = pkgs.fetchurl {
    url = "https://github.com/oven-sh/bun/releases/download/bun-v1.4.2/bun-darwin-aarch64.zip";
    sha256 = "90987a3a16d7db556d886ac3d551e7b6d3edf0a1cf43acaed622e8676be1d12f";
  };
  bunToolchain = pkgs.runCommand "tcut-bun-1.4.2" { nativeBuildInputs = [ pkgs.unzip ]; } ''
    mkdir -p "$out"
    unzip -q ${bunArchive} -d "$out"
  '';
in
{
  home.file.".local/share/tcut/bun" = {
    source = "${bunToolchain}/bun-darwin-aarch64/bun";
    force = true;
  };

  # Reusable capture defaults. tcut reads the current Ghostty theme at capture time.
  xdg.configFile."tcut/capture.json" = {
    force = true;
    text = builtins.toJSON {
      contentRoot = "${config.home.homeDirectory}/workflow/content";
      terminal = "ghostty";
      clipboard = true;
      video = {
        shell = [
          "nu"
          "--no-history"
        ];
        promptPattern = "\\[λ\\]\\s*$";
        cols = 80;
        rows = 40;
        font = {
          family = "Geist Mono";
          size = 16;
          lineHeight = 1.5;
        };
        padding = 24;
        margin = 0;
        marginFill = "transparent";
        windowBar = "none";
        borderRadius = 8;
        typingSpeed = "40ms";
        waitTimeout = "120s";
        endPause = 0;
        core = "ghostty";
        trim = true;
      };
    };
  };
}
