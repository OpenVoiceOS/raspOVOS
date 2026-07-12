# Image variants & languages

## Variants

| Variant | STT | TTS | Intent pipeline | Minimum hardware |
|---------|-----|-----|-----------------|------------------|
| lite | `ovos-stt-plugin-server` (public) | `ovos-tts-plugin-server` (public) | minimal | Pi 3 (might work) |
| hybrid | `ovos-stt-plugin-server` (public) | on-device (piper) | balanced | Pi 4 |
| offline | on-device (citrinet / fasterwhisper) | on-device (piper) | full | Pi 4/5, 4 GB+ RAM |

Release names look like `raspOVOS-<lang>-bookworm-arm64-<variant>.img.xz`.
`DEV`-prefixed releases are the untranslated base images the language
builds derive from — developers only.

## Language-specific plugins

Languages with dedicated TTS plugins:

| lang | tts-plugin |
|------|------------|
| ca | ovos-tts-plugin-matxa-multispeaker-cat |
| gl | ovos-tts-plugin-nos |
| eu | ovos-tts-plugin-ahotts |

STT per language (offline variant):

| lang | stt-plugin | model |
|------|------------|-------|
| en, es, ca, pt, de, it, nl, fr | ovos-stt-plugin-citrinet | per-language citrinet ONNX |
| da, gl, eu | ovos-stt-plugin-fasterwhisper | per-language faster-whisper |

Intent models (`ovos-model2vec-intents-*`) are selected per language where
trained; the multilingual LaBSE model is the fallback.

!!! note
    The per-language matrix is being migrated to a benchmark-backed
    `model_matrix.json` (with phoonnx TTS and onnx-asr STT as the new
    offline defaults). Until then the tables above reflect what ships.

## Known language gaps

- `eu`, `gl`: only female voices available so far
- `pt`: no offline TTS voice yet (hybrid uses an online voice)
- `ca`: offline voice removed for licensing reasons
- `fr`, `da`: no localized "wake up" wake word yet

## Next steps

- [Change the voice or STT](../how-to/change-voice-stt.md)
- [Build manifest](build-manifest.md) — see exactly what your image contains
