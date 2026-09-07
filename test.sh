#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAUNCHER="$SCRIPT_DIR/tergame.sh"
PASS=0
FAIL=0

assert() {
    local desc="$1"
    local expected="$2"
    local actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        echo -e "  \033[0;32mPASS\033[0m: $desc"
        PASS=$((PASS + 1))
    else
        echo -e "  \033[0;31mFAIL\033[0m: $desc (expected: '$expected', got: '$actual')"
        FAIL=$((FAIL + 1))
    fi
}

echo "testing TerGame"

# test 1: help works
OUTPUT=$("$LAUNCHER" help 2>&1)
assert "help shows usage" "true" "$(echo "$OUTPUT" | grep -q "Usage" && echo true || echo false)"

# test 2: list with no games
touch "$SCRIPT_DIR/games.conf"
OUTPUT=$("$LAUNCHER" list 2>&1 || true)
assert "list runs without error" "true" "$(echo "$OUTPUT" | grep -qi "game" && echo true || echo false)"

# test 3: add a fake game
mkdir -p /tmp/test-game
touch /tmp/test-game/fake.exe
"$LAUNCHER" add testgame /tmp/test-game/fake.exe 2>&1
assert "add game creates entry" "true" "$(grep -q "testgame=" "$SCRIPT_DIR/games.conf" && echo true || echo false)"

# test 4: list shows the game
OUTPUT=$("$LAUNCHER" list 2>&1)
assert "list shows added game" "true" "$(echo "$OUTPUT" | grep -q "testgame" && echo true || echo false)"

# test 5: remove game
"$LAUNCHER" remove testgame 2>&1
assert "remove game deletes entry" "true" "$(grep -q "testgame=" "$SCRIPT_DIR/games.conf" && echo false || echo true)"

# test 6: run non-existent game
OUTPUT=$("$LAUNCHER" run nonexistent 2>&1 || true)
assert "run missing game shows error" "true" "$(echo "$OUTPUT" | grep -qi "not found" && echo true || echo false)"

# test 7: syntax check
bash -n "$LAUNCHER" 2>&1
assert "syntax check passes" "true" "$(bash -n "$LAUNCHER" 2>&1 && echo true || echo false)"

# cleanup
rm -rf /tmp/test-game

echo ""
echo "═══════════════════════════════════"
echo -e "Results: \033[0;32m$PASS passed\033[0m, \033[0;31m$FAIL failed\033[0m"
echo "═══════════════════════════════════"

[[ $FAIL -eq 0 ]] && exit 0 || exit 1   