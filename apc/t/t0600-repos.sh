#!/bin/sh

test_description='repos overview from pacman.conf'

. ./test-lib.sh

test_expect_success 'enabled and disabled repos are classified; options skipped' '
	cat >conf <<-EOF &&
	[options]
	HoldPkg = pacman
	[core]
	Include = /etc/pacman.d/mirrorlist
	#[testing]
	Include = x
	[extra]
	Include = x
	EOF
	apc --no-color repos --config conf >out &&
	grep -q "\[core\] enabled" out &&
	grep -q "\[extra\] enabled" out &&
	grep -q "\[testing\] disabled" out &&
	! grep -q "options" out
'

test_expect_success 'unknown option is rejected' '
	test_must_fail apc repos --bogus
'

test_expect_success 'unreadable config errors' '
	test_must_fail apc repos --config no/such/file
'

test_done
