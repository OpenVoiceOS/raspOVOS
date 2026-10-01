# raspOVOS build & test entrypoints.
# CI calls these same targets — no CI-only logic exists anywhere.
#
#   make build VARIANT=lite            build an image locally (needs sudo)
#   make test-static IMG=out.img       Tier 1: static image assertions (~2 min)
#   make test-chroot IMG=out.img       Tier 2: chroot functional checks (~10 min)
#   make test-boot   IMG=out.img       Tier 3: full qemu boot smoke (~20-40 min)
#   make test        IMG=out.img       Tier 1 + Tier 2
#   make dev-shell   IMG=out.img       interactive shell inside the image
#   make lint                          shellcheck over the whole repo

VARIANT ?= lite
IMG ?=

.PHONY: build test test-static test-chroot test-boot dev-shell lint

build:
	./local_build_all.sh --variant $(VARIANT)

test-static:
	@test -n "$(IMG)" || { echo "usage: make test-static IMG=<image>"; exit 1; }
	sudo scripts/ci/assert_image.sh "$(IMG)"

test-chroot:
	@test -n "$(IMG)" || { echo "usage: make test-chroot IMG=<image>"; exit 1; }
	sudo scripts/ci/chroot_checks.sh "$(IMG)" $(VARIANT)

test-boot:
	@test -n "$(IMG)" || { echo "usage: make test-boot IMG=<image>"; exit 1; }
	scripts/ci/qemu_boot_test.sh "$(IMG)"

test: test-static test-chroot

dev-shell:
	@test -n "$(IMG)" || { echo "usage: make dev-shell IMG=<image>"; exit 1; }
	sudo scripts/ci/dev_shell.sh "$(IMG)"

lint:
	./scripts/ci/run_shellcheck.sh
