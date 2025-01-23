#!/usr/bin/env python
import json
import random
import os
import importlib
from langcodes import closest_supported_match
from ovos_plugin_manager.skills import find_skill_plugins


for lang in ["ca", "de", "en", "pt", "fr", "it", "da", "gl", "eu", "es", "nl"]:
    path = f"{os.path.dirname(__file__)}/skills_{lang}.md"
    plugins = find_skill_plugins()
    skills = list(plugins.keys())

    if not skills:
        continue

    with open(path, "w") as f:
        for skill_id, plug in plugins.items():
            p = importlib.import_module(plug.__module__)
            base_dir = os.path.join(os.path.dirname(p.__file__), "locale")

            if not os.path.isdir(base_dir):
                continue

            locale = closest_supported_match(lang, os.listdir(base_dir))
            if locale is None or locale == "und":
                continue

            for root, folders, files in os.walk(os.path.join(base_dir, locale)):
                for intent in [_ for _ in files if _.endswith(".intent")]:
                    print(intent)
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
