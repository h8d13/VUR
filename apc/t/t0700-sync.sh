#!/bin/sh

test_description='update, upgrade, check'

. ./test-lib.sh

test_expect_success 'update force-syncs the dbs (-Syy)' '
	reset_calls &&
	apc --no-color update >out &&
	grep_call "pacman -Syy"
'

test_expect_success 'upgrade runs -Syu' '
	reset_calls &&
	apc --no-color upgrade --noconfirm >out &&
	grep_call "pacman -Syu"
'

# checkupdates exits 2 when up to date; apc maps that to a clean "up to date"
# (exit 0). Either way the command must not error out.
test_expect_success 'check runs checkupdates without erroring' '
	reset_calls &&
	apc --no-color check >out &&
	grep_call checkupdates
'

test_done
