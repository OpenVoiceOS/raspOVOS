---
name: Roadmap task
about: A hand-off-ready task spec for the raspOVOS revival roadmap
title: "[roadmap] "
labels: roadmap
---

## What

<!-- One-sentence outcome. Exact files to touch. Explicit non-goals. -->

## How

<!-- Numbered steps with exact commands. Name an existing file to imitate. -->

## Test

<!-- Commands to run locally + which CI check must go green. New assertions to add. -->

## Document

<!-- Which doc/README/CHANGELOG section to update (path + heading). -->

## Validate (Definition of Done)

- [ ] `./scripts/ci/run_shellcheck.sh` green
- [ ] Relevant CI checks green
- [ ] For new test infra: proven to fail on an injected defect (link the red run)
- [ ] Draft PR into `dev`, conventional commit message
- [ ] CHANGELOG / docs updated if user-facing
