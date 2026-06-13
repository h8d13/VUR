#!/bin/sh
# Run every t[0-9]*.sh, stream a per-script result with pass/fail counts, and
# exit non-zero if any script failed. Full TAP for each script is kept in
# t/<script>.log. Output is TAP, so `(cd t && prove ./t[0-9]*.sh)` also works.
# Pass -v to dump each script's full log inline (handy for CI debugging).

cd "$(dirname "$0")" || exit 1

verbose=
case " $* " in
*" -v "* | *" --verbose "*) verbose=1 ;;
esac

ret=0
for t in t[0-9]*.sh; do
	test -f "$t" || continue
	if sh "$t" "$@" >"$t.log" 2>&1; then
		status=PASS
	else
		status=FAIL
		ret=1
	fi

	# ^ok counts real passes and skips ("ok N # SKIP"); subtract skips.
	ok=$(grep -c '^ok ' "$t.log")
	skip=$(grep -c '# SKIP' "$t.log")
	fail=$(grep -c '^not ok' "$t.log")
	summary="$((ok - skip)) passed"
	test "$skip" -gt 0 && summary="$summary, $skip skipped"
	test "$fail" -gt 0 && summary="$summary, $fail failed"
	echo "$status $t ($summary)"

	# Full log inline when -v; otherwise just the failing lines on FAIL.
	if test -n "$verbose"; then
		sed 's/^/  | /' "$t.log"
	elif test "$status" = FAIL; then
		grep -E '^(not ok|Bail out!|# )' "$t.log" | sed 's/^/    /'
	fi
done
exit $ret
