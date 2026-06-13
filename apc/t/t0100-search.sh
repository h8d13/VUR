#!/bin/sh

test_description='search'

. ./test-lib.sh

test_expect_success 'search sync repos (-Ss)' '
	reset_calls &&
	apc --no-color search bash >out &&
	grep_call "pacman -Ss bash" &&
	grep -qi bash out
'

test_expect_success 'search installed (-Qs) via --local' '
	reset_calls &&
	apc --no-color search bash --local >out &&
	grep_call "pacman -Qs bash"
'

test_expect_success '-l is an alias for --local' '
	reset_calls &&
	apc --no-color search bash -l >out &&
	grep_call "pacman -Qs bash"
'

test_expect_success 'search is the default command' '
	reset_calls &&
	apc --no-color bash >out &&
	grep_call "pacman -Ss bash"
'

test_expect_success 'search with no package errors' '
	test_must_fail apc search
'

test_done
