# Shared helpers for vanilla-plus-arsenal test runners.
# Sourced by tests/run-stack.sh (data-stage stack load). Expects /bin/sh.
set -eu

MOD_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MOD_ID="vanilla-plus-arsenal"
FACTORIO="${FACTORIO_BIN:-$HOME/Library/Application Support/Steam/steamapps/common/Factorio/factorio.app/Contents/MacOS/factorio}"
FACTORIO_MODS="$HOME/Library/Application Support/factorio/mods"
VENDOR_DIR="$MOD_DIR/tests/vendor"

die() { echo "ERROR: $*" >&2; exit 1; }

require_factorio() {
  [ -x "$FACTORIO" ] || die "Factorio binary not found: $FACTORIO (set FACTORIO_BIN)"
}

require_vendor() {
  [ -f "$VENDOR_DIR/parents.json" ] \
    || die "no vendor manifest in $VENDOR_DIR (run: make vendor)"
}

# prepare_work_dir <work> <scenario-name> <check-dir>
# Builds an isolated Factorio user dir: mods/ gets every zip from the live
# vanilla+ mods dir (the save-synced set, mirrored as-is), the vendored
# turret parents, the check's assert mods, and a symlink to this repo as
# the mod under test. Plus saves/, script-output/, scenarios/ and a
# path-mapping config.ini.
prepare_work_dir() {
  work="$1"
  scenario="$2"
  check_dir="$3"

  rm -rf "$work"
  mkdir -p "$work"/mods "$work"/saves "$work"/script-output "$work"/scenarios
  cp -R "$MOD_DIR/tests/scenario/$scenario" "$work/scenarios/$scenario"

  for f in "$FACTORIO_MODS"/*.zip; do
    [ -f "$f" ] && ln -sfn "$f" "$work/mods/$(basename "$f")"
  done
  for f in "$VENDOR_DIR"/*.zip; do
    [ -f "$f" ] && ln -sfn "$f" "$work/mods/$(basename "$f")"
  done
  if [ -n "$check_dir" ] && [ -d "$check_dir/assert-mod" ]; then
    for d in "$check_dir"/assert-mod/*/; do
      [ -d "$d" ] && cp -R "$d" "$work/mods/$(basename "$d")"
    done
  fi

  ln -sfn "$MOD_DIR" "$work/mods/$MOD_ID"

  cat > "$work/config.ini" <<EOF
[path]
read-data=$(dirname "$(dirname "$FACTORIO")")/data
write-data=$work

[general]
locale=en
EOF
}

# write_mod_list <work> [extra-mod-ids...]
# Mirrors the live enabled mod list (built-ins like base and space-age
# included, since they have no zip in mods/) and force-enables the extras
# (vendored parents, assert mods, this mod).
write_mod_list() {
  work="$1"; shift
  python3 - "$FACTORIO_MODS/mod-list.json" "$work/mods/mod-list.json" "$@" <<'EOF'
import json, sys
live = json.load(open(sys.argv[1]))
mods = [m for m in live["mods"] if m["enabled"]]
names = {m["name"] for m in mods}
for extra in sys.argv[3:]:
    if extra not in names:
        mods.append({"name": extra, "enabled": True})
with open(sys.argv[2], "w") as f:
    json.dump({"mods": mods}, f, indent=2)
EOF
}

# run_scenario2map <phase> <work> <scenario>
# Full data-stage load; logs land in <work>/phase-<phase>-scenario2map.log.
run_scenario2map() {
  phase="$1"; work="$2"; scenario="$3"
  echo "--- [$phase] scenario -> map"
  "$FACTORIO" --config "$work/config.ini" --scenario2map "$scenario" \
    --disable-audio > "$work/phase-$phase-scenario2map.log" 2>&1 \
    || { tail -30 "$work/phase-$phase-scenario2map.log"; die "[$phase] scenario2map failed"; }
}

# check_log_patterns <phase> <log-file> <patterns-file>
# Every ERE line in the patterns file must match something in the log.
check_log_patterns() {
  phase="$1"; log_file="$2"; patterns_file="$3"
  line_no=0
  while IFS= read -r pattern || [ -n "$pattern" ]; do
    line_no=$((line_no + 1))
    [ -z "$pattern" ] && continue
    case "$pattern" in \#*) continue ;; esac
    grep -E -- "$pattern" "$log_file" > /dev/null 2>&1 \
      || die "[$phase] expected log pattern not found ($patterns_file:$line_no): $pattern"
  done < "$patterns_file"
}
