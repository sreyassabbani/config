{ lib, pkgs, ... }:
let
  # Card templates and CSS for my note types (see anki/README.md).
  anki-notetypes = pkgs.writeShellApplication {
    name = "anki-notetypes";
    runtimeInputs = [ pkgs.uv ];
    text = ''
      # Use the `anki` library that matches the installed desktop app, so the
      # collection schema is never upgraded behind its back.
      version=""
      for info in /Applications/Anki.app/Contents/Resources/app_packages/anki-*.dist-info; do
        [ -e "$info" ] || continue
        version="''${info##*/anki-}"
        version="''${version%.dist-info}"
      done
      if [ -z "$version" ]; then
        echo "anki-notetypes: Anki.app not found in /Applications" >&2
        exit 1
      fi

      export UV_PYTHON_DOWNLOADS=never
      exec uv run --quiet --no-project --python ${pkgs.python3}/bin/python3 \
        --with "anki==$version" python ${./anki}/apply.py "$@"
    '';
  };
in
{
  home.packages = [ anki-notetypes ];

  # Push template changes on every switch. Anki holds a lock on the
  # collection while it is open, so skip (loudly) rather than fight it.
  home.activation.ankiNotetypes = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if /usr/bin/pgrep -xq Anki; then
      echo "anki-notetypes: Anki is open; run \`anki-notetypes --restart\` to apply card templates"
    elif [ -d "$HOME/Library/Application Support/Anki2" ]; then
      run ${anki-notetypes}/bin/anki-notetypes --quiet \
        || echo "anki-notetypes: failed; card templates not applied" >&2
    fi
  '';
}
