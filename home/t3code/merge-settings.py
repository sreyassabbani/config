"""Apply declared T3 preferences while preserving undeclared runtime settings."""

import json
import os
from pathlib import Path
import sys
import tempfile

import json5


def merge(current, declared):
    result = dict(current)
    for key, value in declared.items():
        if isinstance(value, dict) and isinstance(result.get(key), dict):
            result[key] = merge(result[key], value)
        else:
            result[key] = value
    return result


def apply_settings(directory, declarations):
    pending = []
    # Validate every input before changing any file.
    for name, declared in declarations.items():
        target = directory / name
        if target.is_symlink():
            raise ValueError(f"{target} must be a writable file, not a symlink")
        current = json5.loads(target.read_text()) if target.exists() else {}
        if not isinstance(current, dict) or not isinstance(declared, dict):
            raise ValueError(f"{target} settings must be an object")
        updated = merge(current, declared)
        if updated != current:
            pending.append((target, updated))

    for target, updated in pending:
        target.parent.mkdir(parents=True, exist_ok=True)
        fd, temporary = tempfile.mkstemp(dir=target.parent, prefix=f".{target.name}.")
        try:
            # mkstemp creates mode 0600 files, including when replacing a file.
            with os.fdopen(fd, "w") as stream:
                json.dump(updated, stream, indent=2, ensure_ascii=False)
                stream.write("\n")
            os.replace(temporary, target)
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)


if __name__ == "__main__":
    apply_settings(Path(sys.argv[1]), json.loads(Path(sys.argv[2]).read_text()))
