#!/usr/bin/env python3
"""Download the STT model and the TTS voice the offline configuration names.

An offline image must not need the network the first time it listens or speaks.
The plugins fetch a model at first use, so the model has to be in the image.

This script reads the configuration the build has already written, so it cannot
name a model the image does not select. It asks each plugin's own loader to
fetch, because a configuration value is not a repository id: the STT value
``whisper-base`` is served by the repository ``istupakov/whisper-base-onnx``,
and only the plugin knows that mapping.

Reading the configuration is not enough on its own. The configuration can name
a model that is correct for the language it was written for and wrong for the
image being built, if the build wrote the wrong language tag. So the build must
also say which language it is building, in ``LANG_CODE``, the same value
``write_build_manifest.sh`` already receives, and this script refuses when the
two disagree.

It writes each model into the directory the plugin reads at runtime, not into
the shared Hugging Face cache. The two are different places, and weights in
the cache are weights the runtime fetches again.

It exits non-zero when a fetch fails, and when a fetch leaves no model file
behind. A build that keeps going after a failed bake ships an image that reads
as complete and needs the network at first use, so an exit code is not enough:
this names the files and the bytes it leaves on disk.
"""
import os
import sys
from os.path import join
from typing import List, Tuple

STT_PLUGIN = "ovos-stt-plugin-onnx-asr"
TTS_PLUGIN = "ovos-tts-plugin-phoonnx"


def primary_subtag(tag: str) -> str:
    """The language part of a BCP-47 tag: ``nl`` from ``nl-NL``."""
    return tag.replace("_", "-").split("-")[0].strip().lower()


def check_lang(config_lang) -> str:
    """Refuse when the configuration is not for the language being built.

    ``LANG_CODE`` comes from the build script and names the language of the
    image. ``config_lang`` is what ``ovos-config autoconfigure`` wrote. A build
    that writes the wrong tag selects models for another language, and an
    offline image has no network to correct it, so this is where it stops.
    """
    lang_code = os.environ.get("LANG_CODE", "").strip()
    if not lang_code:
        raise SystemExit(
            "LANG_CODE is not set. The build script must name the language it "
            "is building, so this script can refuse a configuration written "
            "for another language.")
    if not config_lang:
        raise SystemExit("the offline config names no lang")
    want = primary_subtag(lang_code)
    got = primary_subtag(str(config_lang))
    if want != got:
        raise SystemExit(
            f"this build is for {lang_code!r}, but the offline config says "
            f"lang={config_lang!r}. The models it names are for another "
            "language, and an offline image cannot correct that at first use. "
            "Check the --lang tag the build script passes to "
            "'ovos-config autoconfigure'.")
    return lang_code


def read_config() -> dict:
    """The configuration the plugins read at runtime, through ovos-config."""
    from ovos_config import Configuration
    return Configuration()


def stt_model_dir(section: dict, model: str) -> str:
    """The directory ``ovos-stt-plugin-onnx-asr`` reads ``model`` from.

    This repeats the plugin's own ``_model_dir``: the ``model_dir`` config key
    names the root, the default root sits under the XDG data directory, and
    the model id becomes one path segment. A bake that writes anywhere else is
    a bake the runtime does not read.
    """
    from ovos_utils.xdg_utils import xdg_data_home
    root = section.get("model_dir") or join(xdg_data_home(),
                                            "ovos_stt_plugin_onnxasr")
    return join(root, model.replace("/", "--"))


def resolved_size(root: str) -> Tuple[int, int]:
    """The file count and the resolved byte count under ``root``.

    ``st_size`` on a symlink is the length of the link target string, not the
    size of the file, so ``du -sm`` reads 2 MB for a 104 MB model in the
    Hugging Face cache, where every file is a symlink into ``blobs/`` one
    level above the repository directory. This follows the links, the way
    ``du -sm -L`` does, so a report cannot read as empty when the bytes are
    there, and cannot read as full when they are not.
    """
    files = total = 0
    for folder, _, names in os.walk(root):
        for name in names:
            try:
                total += os.stat(os.path.join(folder, name)).st_size
            except OSError:
                # a dangling symlink: an image that copied the repository
                # directory without the blobs it points into
                continue
            files += 1
    return files, total


def weights_in(root: str) -> List[str]:
    """The model files under ``root``, as paths relative to it."""
    found = []
    for folder, _, names in os.walk(root):
        for name in names:
            if name.endswith((".onnx", ".onnx_data")):
                found.append(os.path.relpath(os.path.join(folder, name), root))
    return sorted(found)


def bake_stt(section: dict) -> List[str]:
    """Fetch the onnx-asr model the configuration names. Returns directories.

    ``load_model`` gets the ``path=`` the plugin itself uses. Without it the
    weights land in the shared Hugging Face cache, which the plugin does not
    read: there every file is a symlink to a blob, and onnxruntime resolves a
    symlinked model to its blob before it looks for the sibling
    ``.onnx_data``, which then fails validation. An image baked without
    ``path=`` holds the weights the runtime refuses, and still needs the
    network at first listen.

    ``quantization`` goes through the plugin's ``quantization_for``, because a
    registry model whose repository holds fp32 weights only loads fp32 at
    runtime. A bake that asks for int8 there writes files the runtime does not
    open, and leaves the fp32 weights to fetch at first listen.
    """
    import onnx_asr
    from ovos_stt_plugin_onnxasr.defaults import quantization_for
    model = section.get("model")
    if not model:
        raise SystemExit("offline config names no STT model under "
                         f"stt.{STT_PLUGIN}")
    requested = section.get("quantization")
    quantization = quantization_for(model, requested)
    if quantization != requested:
        print(f"'{model}' has no {requested} weights; baking fp32")
    path = stt_model_dir(section, model)
    print(f"bake STT: {model} quantization={quantization} path={path}")
    # onnx-asr reads an EXISTING path= as an offline model directory and does
    # not download into it (resolver sets offline=True when the directory
    # exists). So the directory must not be created first, and a directory
    # left behind by an interrupted bake never completes: it reports
    # ModelFileNotFoundError and exits non-zero on every later run. Say which
    # of the two it is, because the message onnx-asr gives is the same.
    if os.path.isdir(path):
        if weights_in(path):
            print(f"already baked: {path}")
            return [path]
        raise SystemExit(
            f"{path} exists and holds no .onnx file. onnx-asr treats an "
            f"existing path as an offline model directory and will not "
            f"download into it, so this bake cannot complete. Remove that "
            f"directory and run the bake again.")
    onnx_asr.load_model(model, path=path, quantization=quantization)
    return [path]


def bake_tts(section: dict) -> List[str]:
    """Fetch the phoonnx voice the configuration names."""
    from phoonnx.model_manager import TTSModelManager
    voice = section.get("voice")
    if not voice:
        raise SystemExit("offline config names no TTS voice under "
                         f"tts.{TTS_PLUGIN}")
    print(f"bake TTS: {voice}")
    manager = TTSModelManager()
    manager.merge_default_voices()
    if not manager.download_voice_by_id(voice):
        raise SystemExit(f"phoonnx did not fetch the voice {voice}")
    return [voice]


def cache_report() -> Tuple[str, List[str]]:
    """The shared Hugging Face cache, and the repositories now in it.

    Informational only. The STT plugin does not load from here, so this
    reports what a bake left in the shared cache rather than what the image
    needs.
    """
    try:
        from huggingface_hub import constants
    except ImportError:
        return "", []
    root = constants.HF_HUB_CACHE
    try:
        repos = sorted(n for n in os.listdir(root) if n.startswith("models--"))
    except OSError:
        repos = []
    return root, repos


def main() -> int:
    config = read_config()
    stt_module = config.get("stt", {}).get("module")
    tts_module = config.get("tts", {}).get("module")
    print(f"lang={config.get('lang')} stt.module={stt_module} "
          f"tts.module={tts_module}")
    check_lang(config.get("lang"))
    if stt_module != STT_PLUGIN or tts_module != TTS_PLUGIN:
        raise SystemExit(
            f"this script bakes {STT_PLUGIN} and {TTS_PLUGIN}, but the offline "
            f"config selects {stt_module} and {tts_module}. The tier's "
            "configuration and its baked models must agree.")
    stt_paths = bake_stt(config.get("stt", {}).get(STT_PLUGIN, {}))
    bake_tts(config.get("tts", {}).get(TTS_PLUGIN, {}))
    # The STT directory is what the plugin opens at first listen, so a bake
    # that exits 0 with no weights there is the failure this script exists to
    # prevent. An exit code is not evidence: name the files and the bytes.
    for path in stt_paths:
        files, total = resolved_size(path)
        weights = weights_in(path)
        print(f"stt model dir {path}: {files} files, "
              f"{total / 1e6:.1f} MB resolved")
        for name in weights:
            print(f"  {name}")
        if not weights:
            raise SystemExit(
                f"the bake left no .onnx file in {path}, the directory "
                f"ovos-stt-plugin-onnx-asr reads. An image built from this "
                f"needs the network at first listen.")
    root, repos = cache_report()
    if repos:
        files, total = resolved_size(root)
        print(f"shared Hugging Face cache {root}: {files} files, "
              f"{total / 1e6:.1f} MB resolved (the STT plugin does not read "
              f"this; copy the directories above into the image)")
        for repo in repos:
            print(f"  {repo}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
