.PHONY: test-stack stats lint package install

# Path to the Factorio binary (auto-detected from Steam install on macOS)
FACTORIO_BIN ?= $(HOME)/Library/Application Support/Steam/steamapps/common/Factorio/factorio.app/Contents/MacOS/factorio

VERSION := $(shell sed -n 's/.*"version": "\([^"]*\)".*/\1/p' info.json)
MOD_NAME := vanilla-plus-arsenal
PACKAGE_DIR := $(MOD_NAME)_$(VERSION)
RELEASES_DIR := releases
PACKAGE_ZIP := $(RELEASES_DIR)/$(PACKAGE_DIR).zip

# Default Factorio mods dir per OS for `make install`
UNAME_S := $(shell uname -s 2>/dev/null)
ifeq ($(UNAME_S),Darwin)
	FACTORIO_MODS_DIR ?= $(HOME)/Library/Application Support/factorio/mods
else ifneq ($(filter MINGW% MSYS% CYGWIN%,$(UNAME_S)),)
	FACTORIO_MODS_DIR ?= $(APPDATA)/Factorio/mods
else
	FACTORIO_MODS_DIR ?= $(HOME)/.factorio/mods
endif

# Full-stack data-stage load test: the live save-synced mod set (turret
# parents included) + this mod, asserted via tests/proto/roster.
test-stack:
	FACTORIO_BIN="$(FACTORIO_BIN)" sh tests/run-stack.sh

# Data-stage dump of the live stack + turret stat baseline.
# Work dir mirrors the live mod set, so the dump reflects every parent's
# final data-stage values.
stats:
	@WORK="${TMPDIR:-/tmp}/vpa-stats"; rm -rf "$$WORK"; \
	mkdir -p "$$WORK"/mods "$$WORK"/saves "$$WORK"/script-output "$$WORK"/scenarios; \
	for f in "$(HOME)/Library/Application Support/factorio/mods"/*.zip; do \
	  ln -sfn "$$f" "$$WORK/mods/$$(basename $$f)"; done; \
	cp "$(HOME)/Library/Application Support/factorio/mods/mod-list.json" "$$WORK/mods/mod-list.json"; \
	printf '[path]\nread-data=%s/data\nwrite-data=%s\n\n[general]\nlocale=en\n' \
	  "$$(dirname "$$(dirname "$(FACTORIO_BIN)")")" "$$WORK" > "$$WORK/config.ini"; \
	"$(FACTORIO_BIN)" --config "$$WORK/config.ini" --dump-data --disable-audio; \
	python3 scripts/dump_turret_stats.py "$$WORK/script-output/data-raw-dump.json"

lint:
	luacheck .

# Files shipped in the zip: info.json + Lua are runtime requirements,
# changelog.txt is shown by the in-game mod list and LICENSE must accompany
# MIT-licensed distributions. README.md, tests/, scripts/ and the Makefile
# are repo-only and stay out.
package:
	@echo "Packaging $(MOD_NAME) $(VERSION)..."
	@rm -rf $(PACKAGE_DIR) $(RELEASES_DIR)
	@mkdir -p $(RELEASES_DIR)
	@mkdir -p $(PACKAGE_DIR)
	@cp -r changelog.txt data-final-fixes.lua info.json LICENSE $(PACKAGE_DIR)/
	@[ ! -d arsenal ] || cp -r arsenal $(PACKAGE_DIR)/
	@[ ! -f settings.lua ] || cp settings.lua $(PACKAGE_DIR)/
	@[ ! -d locale ] || cp -R locale $(PACKAGE_DIR)/ 2>/dev/null || true
	@zip -r $(PACKAGE_DIR).zip $(PACKAGE_DIR) >/dev/null
	@mv $(PACKAGE_DIR).zip $(RELEASES_DIR)/
	@rm -rf $(PACKAGE_DIR)
	@echo "Created $(PACKAGE_ZIP)"

install: package
	@mkdir -p "$(FACTORIO_MODS_DIR)"
	@rm -rf "$(FACTORIO_MODS_DIR)/$(PACKAGE_DIR)"
	@cp "$(PACKAGE_ZIP)" "$(FACTORIO_MODS_DIR)/"
	@echo "Installed $(PACKAGE_DIR).zip to $(FACTORIO_MODS_DIR)"
