"""Write the note types in notetypes.json into an Anki collection.

Only template text and CSS change. Fields and the number of card templates are
left alone, so the change syncs to AnkiWeb as a normal sync (no full upload).
Note types not listed in notetypes.json are untouched.
"""

from __future__ import annotations

import argparse
import difflib
import json
import subprocess
import sys
import time
from pathlib import Path

ANKI2 = Path.home() / "Library/Application Support/Anki2"


def anki_running() -> bool:
    return subprocess.run(["/usr/bin/pgrep", "-xq", "Anki"]).returncode == 0


def quit_anki() -> None:
    # Anki answers AppleScript's `quit` with "User canceled", but it handles
    # SIGTERM like ⌘Q: it closes its windows, syncs if set to, and closes the
    # collection.
    subprocess.run(["/usr/bin/pkill", "-TERM", "-x", "Anki"], check=False)
    for _ in range(120):
        if not anki_running():
            return
        time.sleep(0.5)
    sys.exit(
        "anki-notetypes: Anki did not quit within a minute (an editor window\n"
        "may be asking about unsaved changes); nothing changed"
    )


def default_collection() -> Path:
    found = sorted(ANKI2.glob("*/collection.anki2"))
    if len(found) != 1:
        names = ", ".join(p.parent.name for p in found) or "none"
        sys.exit(f"anki-notetypes: pass --collection (profiles found: {names})")
    return found[0]


def load_spec(root: Path) -> dict[str, dict]:
    spec = json.loads((root / "notetypes.json").read_text())
    out: dict[str, dict] = {}
    for name, entry in spec.items():
        css = "\n".join((root / "notetypes" / f).read_text() for f in entry["css"])
        templates = {
            tmpl: tuple((root / "notetypes" / f).read_text().strip() for f in files)
            for tmpl, files in entry["templates"].items()
        }
        out[name] = {"css": css.strip() + "\n", "templates": templates}
    return out


def show_diff(label: str, old: str, new: str) -> None:
    sys.stdout.writelines(
        difflib.unified_diff(
            old.splitlines(keepends=True),
            new.splitlines(keepends=True),
            f"{label} (collection)",
            f"{label} (config)",
        )
    )
    print()


def main() -> None:
    p = argparse.ArgumentParser(prog="anki-notetypes", description=__doc__)
    p.add_argument("--collection", type=Path, help="defaults to the only Anki2 profile")
    p.add_argument("--dry-run", action="store_true", help="show what would change")
    p.add_argument("--diff", action="store_true", help="print diffs of changed text")
    p.add_argument(
        "--restart",
        action="store_true",
        help="quit Anki if it is open, apply, then reopen it (it syncs on open)",
    )
    p.add_argument("--quiet", action="store_true")
    args = p.parse_args()

    root = Path(__file__).resolve().parent
    spec = load_spec(root)
    path = (args.collection or default_collection()).expanduser()
    if not path.exists():
        sys.exit(f"anki-notetypes: no collection at {path}")

    reopen = False
    live = path.resolve().is_relative_to(ANKI2.resolve())
    if live and not args.dry_run and anki_running():
        if not args.restart:
            sys.exit(
                "anki-notetypes: Anki is open and has the collection locked.\n"
                "Quit it first, or run `anki-notetypes --restart`."
            )
        quit_anki()
        reopen = True

    from anki.collection import Collection

    col = Collection(str(path))
    changed: list[str] = []
    try:
        for name, want in spec.items():
            model = col.models.by_name(name)
            if model is None:
                print(f"skip {name!r}: not in this collection", file=sys.stderr)
                continue
            have = {t["name"]: t for t in model["tmpls"]}
            if set(have) != set(want["templates"]):
                sys.exit(
                    f"anki-notetypes: {name!r} has templates {sorted(have)}, "
                    f"config has {sorted(want['templates'])}. Adding or removing "
                    "templates forces a full sync; do that in Anki desktop."
                )

            dirty = False
            if model["css"] != want["css"]:
                if args.diff:
                    show_diff(f"{name} css", model["css"], want["css"])
                model["css"] = want["css"]
                dirty = True
            for tmpl_name, (qfmt, afmt) in want["templates"].items():
                tmpl = have[tmpl_name]
                for key, text in (("qfmt", qfmt), ("afmt", afmt)):
                    if tmpl[key] != text:
                        if args.diff:
                            show_diff(f"{name} / {tmpl_name} / {key}", tmpl[key], text)
                        tmpl[key] = text
                        dirty = True

            if dirty:
                changed.append(name)
                if not args.dry_run:
                    col.models.update_dict(model)
    finally:
        col.close()

    if not args.quiet or changed:
        verb = "would update" if args.dry_run else "updated"
        print(f"anki-notetypes: {verb} {', '.join(changed)}" if changed else "anki-notetypes: up to date")

    if reopen:
        subprocess.run(["/usr/bin/open", "-a", "Anki"], check=False)


if __name__ == "__main__":
    main()
