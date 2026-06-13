#!/bin/sh

test_description='info and its files-db queries'

. ./test-lib.sh

test_expect_success 'sync info (-Sii)' '
	reset_calls &&
	apc --no-color info bash >out &&
	grep_call "pacman -Sii bash" &&
	grep -q "^Name " out
'

test_expect_success 'local info (-Qii) via --local' '
	reset_calls &&
	apc --no-color info bash --local >out &&
	grep_call "pacman -Qii bash" &&
	grep -q "^Name " out
'

test_expect_success '--files lists provided files (-Fl), after -Fy refresh' '
	reset_calls &&
	apc --no-color info bash --files >out &&
	grep_call "pacman -Fy" &&
	grep_call "pacman -Fl bash"
'

test_expect_success '--why PATH finds provider (-F), after -Fy refresh' '
	reset_calls &&
	apc --no-color info --why /usr/bin/bash >out &&
	grep_call "pacman -Fy" &&
	grep_call "pacman -F /usr/bin/bash"
'

test_expect_success 'short aliases -l/-f/-w match their long forms' '
	reset_calls && apc --no-color info bash -l >out && grep_call "pacman -Qii bash" &&
	reset_calls && apc --no-color info bash -f >out && grep_call "pacman -Fl bash" &&
	reset_calls && apc --no-color info -w /usr/bin/bash >out && grep_call "pacman -F /usr/bin/bash"
'

test_expect_success 'plain info does not refresh files db' '
	reset_calls &&
	apc --no-color info bash >out &&
	! grep_call "pacman -Fy"
'

test_expect_success 'info with no package errors' '
	test_must_fail apc info
'

test_done
