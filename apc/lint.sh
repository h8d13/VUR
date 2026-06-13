#!/bin/bash
SCRIPT="./apc"
TESTS_PASSED=0
TESTS_FAILED=0

echo "Running lints on $SCRIPT..."
echo

echo "▶ Running bash -n..."
if bash -n "$SCRIPT"; then
	echo "  ✓ Syntax check passed"
	((TESTS_PASSED++))
else
	echo "  ✗ Syntax check failed"
	((TESTS_FAILED++))
fi
echo

echo "▶ Running shellcheck..."
if shellcheck "$SCRIPT"; then
	echo "  ✓ Shellcheck passed"
	((TESTS_PASSED++))
else
	echo "  ✗ Shellcheck failed"
	((TESTS_FAILED++))
fi
echo

echo "▶ Checking shfmt formatting..."
if shfmt -i 0 -d "$SCRIPT" >/dev/null 2>&1; then
	echo "  ✓ Formatting is correct"
	((TESTS_PASSED++))
else
	echo "  ✗ Formatting needs adjustment"
	echo "  Run: shfmt -i 0 -w $SCRIPT"
	((TESTS_FAILED++))
fi
echo

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit "$TESTS_FAILED"
