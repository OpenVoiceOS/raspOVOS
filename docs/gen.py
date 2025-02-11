#!/usr/bin/env python
import importlib
import json
import os
import random

from langcodes import closest_supported_match
from ovos_plugin_manager.skills import find_skill_plugins
from ovos_utils.bracket_expansion import expand_template

for lang in ["ca", "de", "en", "pt", "fr", "it", "da", "gl", "eu", "es", "nl"]:
    path = f"{os.path.dirname(__file__)}/skills_{lang}.md"
    plugins = find_skill_plugins()
    skills = list(plugins.keys())
    CSV = "domain,intent,utterance"
    if not skills:
        continue

    with open(path, "w") as f:
        for skill_id in sorted(skills):
            plug = plugins[skill_id]
            p = importlib.import_module(plug.__module__)
            base_dir = os.path.join(os.path.dirname(p.__file__), "locale")

            if not os.path.isdir(base_dir):
                continue

            locale = closest_supported_match(lang, os.listdir(base_dir))
            if locale is None or locale == "und":
                continue

            for root, folders, files in os.walk(os.path.join(base_dir, locale)):
                for intent in [_ for _ in files if _.endswith(".intent")]:
                    p = f"{root}/{intent}"
                    with open(p) as ifile:
                        lines = ifile.read().split("\n")
                    for l in lines:
                        if not l or l.startswith("#"):
                            continue
                        for l2 in expand_template(l):
                            if not l2:
                                continue
                            CSV += f"\n{skill_id},\"{intent}\",\"{l2}\""
                if "skill.json" in files:
                    with open(os.path.join(root, "skill.json")) as fi:
                        data = json.load(fi)
                        if not data.get("examples"):
                            continue
                        random.shuffle(data["examples"])
                        f.write(f"\n### {skill_id.lower()}\n")
                        f.write(
                            f"\n{data.get('description', 'No description available')}")
                        f.write(f"\n\n**Usage examples:**")
                        for example in data["examples"][:10]:
                            f.write(f"\n- {example}")
                        f.write("\n\n-------\n\n")

    with open(f"{os.path.dirname(__file__)}/intents_{lang}.csv", "w") as f:
        f.write(CSV)
