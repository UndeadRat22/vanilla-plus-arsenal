#!/bin/sh
# Full-stack data-stage load test for vanilla-plus-arsenal (A/B).
#
# Phase A loads the live vanilla+ mod set WITHOUT this mod and asserts the
# base values (vanilla turret stats); Phase B adds this mod and asserts
# the roster, the parents' turret prototypes, and the buffed values.
# Same harness pattern as k2so-rats-fixes' tests/run-proto.sh.
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

echo "=== Phase A: base stack, no vanilla-plus-arsenal ==="
prepare_work_dir "$WORK" proto-check "$CHECK_DIR" 0
write_mod_list "$WORK" $assert_ids
run_scenario2map A "$WORK" proto-check
check_log_patterns A "$WORK/phase-A-scenario2map.log" "$CHECK_DIR/expected-A.txt"
echo "Phase A passed (base state confirmed)."

echo
echo "=== Phase B: with vanilla-plus-arsenal ==="
# same work dir, add the mod under test (k2so-rats-fixes' run-proto pattern)
ln -sfn "$MOD_DIR" "$WORK/mods/$MOD_ID"
write_mod_list "$WORK" $assert_ids vanilla-plus-arsenal
run_scenario2map B "$WORK" proto-check
check_log_patterns B "$WORK/phase-B-scenario2map.log" "$CHECK_DIR/expected-B.txt"
echo "Phase B passed (roster + buffs verified)."

echo
echo "STACK LOAD PASSED (logs in $WORK)"
