#!/usr/bin/env python3
"""Download a phoonnx voice and check its model file is really in the cache.

Two reasons this is a script and not two lines of shell:

* `phoonnx-voices download` calls `TTSModelManager.load()`, which reads the XDG
  voice cache. On an image that never ran phoonnx that cache file does not
  exist and json_database raises DatabaseNotCommitted, so the command cannot
  download a voice on a fresh image at all. This script goes to the bundled
  voice index directly, which needs no cache.
* The command also catches its own network errors and exits 0, and the hub
  repository is not named after the voice id, so a build cannot tell a
  downloaded voice from a missing one by looking for a directory.

Usage: check_phoonnx_voice.py <voice-id>
Exits 1 when the voice is not in the bundled index, or has no model file.
"""
import json
import sys

from importlib.metadata import version

from phoonnx.model_manager import TTSModelInfo, TTSModelManager


def find(voice_id: str):
    """Give the voice's index entry, from the bundled indexes."""
    manager = TTSModelManager()
    info = manager.voices.get(voice_id)
    if info:
        return info
    for path in manager.voice_index_files():
        with open(path, "r", encoding="utf-8") as index:
            data = json.load(index)
        if voice_id in data:
            return TTSModelInfo(**data[voice_id])
    return None


def main(voice_id: str) -> int:
    print(f"phoonnx {version('phoonnx')}")
    info = find(voice_id)
    if not info:
        print(f"ERROR: {voice_id} is not in the bundled voice index")
        return 1
    info.download_all()
    model = info.download_model()
    if not model or not model.is_file() or model.stat().st_size == 0:
        print(f"ERROR: {voice_id} has no model file at {model}")
        return 1
    print(f"voice model: {model} ({model.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(2)
    sys.exit(main(sys.argv[1]))
