#!/bin/sh

test_description='deps'

. ./test-lib.sh

test_expect_success 'deps runs pactree on a real package' '
	reset_calls &&
	apc --no-color deps bash >out &&
	grep_call "pactree bash" &&
	grep -q bash out
'

test_expect_success 'deps passes flags through' '
	reset_calls &&
	apc --no-color deps bash --depth 1 >out &&
	grep_call "pactree bash --depth 1"
'

test_expect_success 'deps with no package errors' '
	test_must_fail apc deps
'

test_done
