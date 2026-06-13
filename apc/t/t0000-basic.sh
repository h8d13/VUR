#!/bin/sh

test_description='help, version, and default-command dispatch'

. ./test-lib.sh

# Read the version from the script instead of hardcoding it, so a bump doesn't
# break the suite.
ver=$(sed -n 's/^VER_STRING="\(.*\)"/\1/p' "$apc")

test_expect_success 'no args calls pacman directly (no help, no search)' '
	reset_calls &&
	test_must_fail apc >out &&
	grep_call "pacman" &&
	! grep_call "pacman -Ss" &&
	! grep -q "apc - Wrapper for common pacman" out
'

test_expect_success 'help renders the synopsis and commands' '
	apc help >out &&
	grep -q "SYNOPSIS" out &&
	grep -q "COMMANDS" out
'

test_expect_success '--version prints version and runs pacman -V' '
	reset_calls &&
	apc --version >out &&
	grep -q "Apc $ver" out &&
	grep_call "pacman -V"
'

test_expect_success '-h and -v / version are aliases for help and version' '
	apc -h >out && grep -q "SYNOPSIS" out &&
	apc version >out && grep -q "Apc $ver" out &&
	apc -v >out && grep -q "Apc $ver" out
'

test_expect_success 'unknown command falls back to search' '
	reset_calls &&
	apc --no-color bash >out &&
	grep_call "pacman -Ss bash"
'

test_expect_success '--no-color strips ANSI from op lines' '
	apc --no-color list --local >out &&
	! grep -q "$(printf "\033")" out
'

test_done
