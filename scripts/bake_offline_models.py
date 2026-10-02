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

It exits non-zero when a fetch fails. A build that keeps going after a failed
bake ships an image that reads as complete and needs the network at first use.
"""
import os
import sys
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


def bake_stt(section: dict) -> List[str]:
    """Fetch the onnx-asr model the configuration names. Returns cache names."""
    import onnx_asr
    model = section.get("model")
    if not model:
        raise SystemExit("offline config names no STT model under "
                         f"stt.{STT_PLUGIN}")
    quantization = section.get("quantization")
    print(f"bake STT: {model} quantization={quantization}")
    if quantization:
        onnx_asr.load_model(model, quantization=quantization)
    else:
        onnx_asr.load_model(model)
    return [model]


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
    """The cache directory, and the repositories now in it."""
    from huggingface_hub import constants
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
    bake_stt(config.get("stt", {}).get(STT_PLUGIN, {}))
    bake_tts(config.get("tts", {}).get(TTS_PLUGIN, {}))
    root, repos = cache_report()
    print(f"cache {root}")
    for repo in repos:
        print(f"  {repo}")
    if not repos:
        raise SystemExit(f"nothing is in {root} after the bake")
    return 0


if __name__ == "__main__":
    sys.exit(main())
