# Build manifest

Every image carries `/opt/ovos/build-manifest.json`: the exact provenance
of the build. Attach it to bug reports — it maps your image to exact
package pins.

```bash
python3 -m json.tool /opt/ovos/build-manifest.json | less
```

## Schema

| Key | Meaning |
|-----|---------|
| `variant` | `lite` / `offline` (base) — lang builds keep the base variant name |
| `lang` | language code for language images, empty for base images |
| `build_date` | UTC ISO timestamp of provisioning |
| `base_os` | `PRETTY_NAME` of the underlying Raspberry Pi OS |
| `python_abi` | e.g. `cp311` — the ABI prebuilt wheels were selected for |
| `constraints` | the ovos-releases constraints file URL used for pinning |
| `base_image_url` | the image this build layered on top of |
| `git_sha` | raspOVOS commit that built the image |
| `workflow_run` | link to the GitHub Actions run |
| `resolved_packages` | full `pip freeze` of the OVOS venv at build time |

The manifest is written by `scripts/write_build_manifest.sh` at the end of
provisioning and re-written by each language build so `lang` is accurate.
