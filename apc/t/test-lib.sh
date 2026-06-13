#!/bin/sh
# Minimal test harness for apc, modeled on git's t/test-lib.sh (a small
# subset). A test script sets test_description, sources this file, runs
# test_expect_success blocks, and ends with test_done. Run from within t/.
#
# CI-ONLY. These tests run the REAL pacman/checkupdates/paccache/pactree/
# reflector and really install/remove packages, refresh the files db, and
# force-sync. Run them in the disposable CI container, never on a host. Each
# real tool is fronted by a thin wrapper that logs its argv to $apc_CALLS and
# then execs the real binary -- a tap for flag assertions, not a fake. See README.

# Resolve paths (TEST_DIRECTORY = the t/ dir, apc = binary under test).
TEST_DIRECTORY=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
apc="${apc:-$TEST_DIRECTORY/../apc}"
if ! test -f "$apc"; then
	echo "Bail out! apc not found at $apc"
	exit 1
fi

# Options
verbose= immediate=
for opt in "$@"; do
	case "$opt" in
	-v | --verbose) verbose=t ;;
	-i | --immediate) immediate=t ;;
	-h | --help)
		echo "usage: $0 [-v] [-i]"
		exit 0
		;;
	*)
		echo "unknown option: $opt" >&2
		exit 1
		;;
	esac
done

# TAP counters
test_count=0 test_success=0 test_failure=0

# Body stdout/stderr go to fd3/4: shown only under -v, so TAP on fd1 stays clean.
if test -n "$verbose"; then
	exec 3>&1 4>&2
else
	exec 3>/dev/null 4>/dev/null
fi

# Prereqs: a test may carry an optional PREREQ (or !PREREQ) as its first arg.
satisfied_prereq=" "
test_set_prereq() { satisfied_prereq="$satisfied_prereq$1 "; }
test_have_prereq() {
	p=$1
	test -z "$p" && return 0
	neg=
	case "$p" in !*)
		neg=t
		p=${p#!}
		;;
	esac
	case "$satisfied_prereq" in
	*" $p "*) test -z "$neg" ;;
	*) test -n "$neg" ;;
	esac
}
test "$(id -u)" = 0 && test_set_prereq ROOT

# Per-test cleanup, run whether the body passed or failed (like git's).
test_cleanup=:
test_when_finished() { test_cleanup="{ $*; }; $test_cleanup"; }

test_expect_success() {
	if test $# -eq 3; then
		prereq=$1
		shift
	else
		prereq=
	fi
	test_count=$((test_count + 1))
	if ! test_have_prereq "$prereq"; then
		echo "ok $test_count - $1 # SKIP (prereq $prereq)"
		return
	fi
	test_cleanup=:
	if eval >&3 2>&4 "$2" && eval >&3 2>&4 "$test_cleanup"; then
		test_success=$((test_success + 1))
		echo "ok $test_count - $1"
	else
		eval >&3 2>&4 "$test_cleanup" || :
		test_failure=$((test_failure + 1))
		echo "not ok $test_count - $1"
		test -n "$immediate" && {
			echo "Bail out! failed: $1"
			exit 1
		}
	fi
}

# Inverted expectation: succeeds only if the command FAILS (non-zero).
test_must_fail() {
	"$@"
	ret=$?
	if test $ret -eq 0; then
		echo "test_must_fail: command unexpectedly succeeded: $*" >&4
		return 1
	fi
	return 0
}

test_cmp() { diff -u "$@"; }

test_done() {
	echo "1..$test_count"
	if test "$test_failure" -gt 0; then
		echo "# failed $test_failure of $test_count tests" >&2
		exit 1
	fi
	exit 0
}

# --- sandbox: trash dir + real-tool loggers on PATH ------------------------
# Space in the trash name is deliberate: it catches quoting bugs, like git's.
TRASH_DIRECTORY="$TEST_DIRECTORY/trash.$(basename "$0" .sh)"
rm -rf "$TRASH_DIRECTORY"
mkdir -p "$TRASH_DIRECTORY/bin"
apc_CALLS="$TRASH_DIRECTORY/calls"
: >"$apc_CALLS"
export apc_CALLS

# Front each real tool with a logger that records argv then execs the real
# binary by absolute path (resolved now, before the wrapper dir shadows PATH).
for tool in pacman checkupdates paccache pactree reflector; do
	real=$(command -v "$tool" 2>/dev/null) || real=
	test -n "$real" || continue
	{
		echo '#!/bin/sh'
		echo "echo \"$tool \$*\" >>\"\$apc_CALLS\""
		echo "exec $real \"\$@\""
	} >"$TRASH_DIRECTORY/bin/$tool"
done
chmod +x "$TRASH_DIRECTORY/bin/"* 2>/dev/null || true
PATH="$TRASH_DIRECTORY/bin:$PATH"
export PATH

# Test-facing helpers. reset_calls before an apc call, then grep_call asserts
# which underlying command it issued. (The logger also records pacman calls the
# test itself makes, so reset_calls right before the apc under test.)
apc() { "$apc" "$@"; }
reset_calls() { : >"$apc_CALLS"; }
grep_call() { grep -F -- "$1" "$apc_CALLS"; }

cd "$TRASH_DIRECTORY" || exit 1
