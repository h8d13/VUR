#!/bin/sh

test_description='list and its query modes'

. ./test-lib.sh

test_expect_success 'list sync packages (-Sl)' '
	reset_calls &&
	apc --no-color list >out &&
	grep_call "pacman -Sl" &&
	test -s out
'

test_expect_success '--local lists installed, incl. bash (-Q)' '
	reset_calls &&
	apc --no-color list --local >out &&
	grep_call "pacman -Q" &&
	grep -q "^bash " out
'

test_expect_success '--explicit (-Qe)' '
	reset_calls &&
	apc --no-color list --explicit >out &&
	grep_call "pacman -Qe"
'

test_expect_success '--files PKG lists owned files (-Ql)' '
	reset_calls &&
	apc --no-color list --files bash >out &&
	grep_call "pacman -Ql bash" &&
	grep -q "/usr/bin/bash" out
'

test_expect_success '--why PATH finds the owner (-Qo)' '
	reset_calls &&
	apc --no-color list --why /usr/bin/bash >out &&
	grep_call "pacman -Qo /usr/bin/bash" &&
	grep -qi bash out
'

test_expect_success 'short aliases -l/-e/-f/-w match their long forms' '
	reset_calls && apc --no-color list -l >out && grep_call "pacman -Q" &&
	reset_calls && apc --no-color list -e >out && grep_call "pacman -Qe" &&
	reset_calls && apc --no-color list -f bash >out && grep_call "pacman -Ql bash" &&
	reset_calls && apc --no-color list -w /usr/bin/bash >out && grep_call "pacman -Qo /usr/bin/bash"
'

# --first/--last read local-db dir mtimes. The newest entry should be a real
# name-version-rel line; exact identity is asserted in t0400 after an install.
test_expect_success '--last 1 returns a real newest package line' '
	apc --no-color list --last 1 >out &&
	tail -n 1 out >name &&
	test -s name &&
	grep -q -- - name
'

test_expect_success '--first 1 returns a real oldest package line' '
	apc --no-color list --first 1 >out &&
	tail -n 1 out >name &&
	test -s name &&
	grep -q -- - name
'

test_done
