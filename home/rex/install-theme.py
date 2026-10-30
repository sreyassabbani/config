"""Merge the managed Rex theme into the user's existing custom themes."""
import json
import os
import plistlib
import subprocess
import sys


def defaults(*args):
    return subprocess.run(["/usr/bin/defaults", *args], check=True, capture_output=True).stdout


theme = json.load(open(sys.argv[1], encoding="utf-8"))
try:
    prefs = plistlib.loads(defaults("export", "com.superlogical.rex", "-"))
except subprocess.CalledProcessError:
    if os.path.exists(os.path.expanduser("~/Library/Preferences/com.superlogical.rex.plist")):
        raise
    prefs = {}

raw = prefs.get("Workspace.customThemes", b"[]")
themes = json.loads(raw)
if not isinstance(themes, list):
    raise ValueError("Rex custom themes are not a list; refusing to overwrite them")
updated = [item for item in themes if item.get("id") != theme["id"]]
updated.append(theme)
if updated != themes:
    data = json.dumps(updated, ensure_ascii=False, separators=(",", ":")).encode().hex()
    defaults("write", "com.superlogical.rex", "Workspace.customThemes", "-data", data)
if prefs.get("Workspace.darkThemeID") != theme["id"]:
    defaults("write", "com.superlogical.rex", "Workspace.darkThemeID", "-string", theme["id"])
