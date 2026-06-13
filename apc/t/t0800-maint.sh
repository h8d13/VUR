#!/bin/sh

test_description='clean and orphs'

. ./test-lib.sh

test_expect_success 'clean runs paccache -r' '
	reset_calls &&
	apc --no-color clean >out &&
	grep_call "paccache -r"
'

test_expect_success 'clean passes flags through' '
	reset_calls &&
	apc --no-color clean -k1 >out &&
	grep_call "paccache -r -k1"
'

# Clear any pre-existing orphans (removing one can expose its deps as new
# orphans, hence the loop) so the next test sees a clean slate.
test_expect_success 'orphs with none reports nothing and skips removal' '
	while o=$(pacman -Qdtq 2>/dev/null) && test -n "$o"; do
		pacman -Rns --noconfirm $o || break
	done &&
	reset_calls &&
	apc --no-color orphs >out &&
	grep -q "no orphans" out &&
	! grep_call "pacman -Rns"
'

# A package installed --asdeps that nothing requires IS an orphan: orphs must
# find it via -Qdtq and remove it via -Rns.
test_expect_success 'orphs removes a real orphan (-Qdtq, then -Rns)' '
	pacman -S --asdeps --noconfirm tree &&
	test_when_finished "pacman -Rns --noconfirm tree 2>/dev/null || true" &&
	reset_calls &&
	apc --no-color orphs --noconfirm >out &&
	grep_call "pacman -Qdtq" &&
	grep_call "pacman -Rns" &&
	! pacman -Q tree
'

test_done
