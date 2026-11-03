import importlib.util
import json
from pathlib import Path
import stat
import tempfile
import unittest


spec = importlib.util.spec_from_file_location(
    "merge_settings", Path(__file__).with_name("merge-settings.py")
)
settings = importlib.util.module_from_spec(spec)
spec.loader.exec_module(settings)


class MergeSettingsTest(unittest.TestCase):
    def test_preserves_runtime_fields_and_does_not_rewrite_unchanged_files(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            target = directory / "settings.json"
            target.write_text('''{
              // T3 also accepts JSON5.
              providerInstances: {codex: {config: {binaryPath: "codex", homePath: "keep"}}},
              projectSettingsOverrides: {project: {defaultThreadEnvMode: "worktree"}},
              favorites: ["old"],
            }''')
            declared = {"settings.json": {
                "providerInstances": {"codex": {"config": {"binaryPath": "/new/codex"}}},
                "favorites": ["new"],
            }}

            settings.apply_settings(directory, declared)
            current = json.loads(target.read_text())
            self.assertEqual(current["providerInstances"]["codex"]["config"], {
                "binaryPath": "/new/codex", "homePath": "keep",
            })
            self.assertEqual(current["projectSettingsOverrides"], {
                "project": {"defaultThreadEnvMode": "worktree"},
            })
            self.assertEqual(current["favorites"], ["new"])
            self.assertEqual(stat.S_IMODE(target.stat().st_mode), 0o600)
            modified = target.stat().st_mtime_ns
            settings.apply_settings(directory, declared)
            self.assertEqual(target.stat().st_mtime_ns, modified)

    def test_invalid_second_file_prevents_all_writes(self):
        for invalid in ["{broken", "[]"]:
            with self.subTest(invalid=invalid), tempfile.TemporaryDirectory() as temporary:
                directory = Path(temporary)
                first = directory / "settings.json"
                second = directory / "client-settings.json"
                first.write_text('{"keep": true}')
                second.write_text(invalid)
                with self.assertRaises(ValueError):
                    settings.apply_settings(directory, {
                        "settings.json": {"new": True},
                        "client-settings.json": {"new": True},
                    })
                self.assertEqual(first.read_text(), '{"keep": true}')
                self.assertEqual(second.read_text(), invalid)

    def test_bootstraps_a_missing_directory(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary) / "userdata"
            settings.apply_settings(directory, {"settings.json": {"idleCompaction": "onReturn"}})
            self.assertEqual(json.loads((directory / "settings.json").read_text()), {
                "idleCompaction": "onReturn",
            })


if __name__ == "__main__":
    unittest.main()
