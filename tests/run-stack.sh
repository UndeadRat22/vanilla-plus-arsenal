#!/bin/sh
# Full-stack data-stage load test for vanilla-plus-arsenal.
#
# Loads the live vanilla+ mod set (mirrored from the save-synced mods dir
# and mod-list.json, turret parents included) plus this mod and the roster
# assert mod, through --scenario2map - the same harness pattern as
# k2so-rats-fixes' tests/run-proto.sh.
#
# Usage: make test-stack   (or: sh tests/run-stack.sh)
# Env:   FACTORIO_BIN, WORK (work dir override)
. "$(dirname "$0")/lib.sh"

require_factorio

CHECK_DIR="$MOD_DIR/tests/proto/roster"
WORK="${WORK:-${TMPDIR:-/tmp}/vpa-stack-e2e}/full"

assert_ids=""
for d in "$CHECK_DIR"/assert-mod/*/; do
  [ -d "$d" ] && assert_ids="$assert_ids $(basename "$d")"
done
[ -n "$assert_ids" ] || die "no assert mod under $CHECK_DIR/assert-mod"

echo "=== vanilla-plus-arsenal stack load ==="
prepare_work_dir "$WORK" proto-check "$CHECK_DIR"
write_mod_list "$WORK" $assert_ids vanilla-plus-arsenal
run_scenario2map B "$WORK" proto-check
check_log_patterns B "$WORK/phase-B-scenario2map.log" "$CHECK_DIR/expected-B.txt"

echo
echo "STACK LOAD PASSED (logs in $WORK)"
