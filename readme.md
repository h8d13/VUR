# Arch Closed Repository - State

- All commits require:
	- A valid `GPG` key to sign all commits + SSH setup (web commits will not be accepted)
	- A valid DCO trailer: using `--signoff` or `-s` with `git`
	- Any web commits require an email linked and verified
	- A valid review from the dictator himself

- All commits on `master`:
	- Require linear history
	- Only through PRs

## Package rules

Every `pkgs/<name>/` recipe must satisfy (enforced by `./check`):

1. **Tracked-upstream source, by suffix.** Every `pkgname` ends in one of:
   - `-git` — `source=()` is a `git+` VCS source (built from a clone), or
   - `-rel` — `source=()` is a `releases/download/` URL (a published git tag).

   Both track upstream git; they differ only in whether we build the clone or
   install a published release artifact. No other source suffix is allowed.
   A trailing `-sys` may be appended to either (`-git-sys` / `-rel-sys`) — see
   rule 2.
2. **No `.install` scriptlets, unless the package is `-sys`.** By default a
   recipe may have no `install=` line and no `*.install` file. A package that
   genuinely needs pre/post scriptlets (systemd units, user creation, cache
   refresh, …) must opt in by appending `-sys` to its `pkgname`
   (e.g. `foo-git-sys`). Only `*-sys/` dirs can commit a `*.install` — the
   allowlist forbids it everywhere else.
3. **At least one `# Maintainer:` line** in the PKGBUILD.

Run `./check` before committing; CI runs it on every PR.

## Recipe allowlist

Under `pkgs/`, only packaging files are tracked — all source code and build
artifacts are ignored, whatever the language. The `.gitignore` allowlist:

- `PKGBUILD`, `.SRCINFO`, `.nvchecker.toml`
- `*.patch`, `*.diff`, `*.hook`
- `*.service`, `*.sysusers`, `*.tmpfiles`, `*.desktop`
- `keys/**/*.asc`

Anything else in a recipe dir (`.sh`, `.py`, `.rs`, tests, downloaded
tarballs, `pkg/`, `src/`, built packages) is never committed.

## Tooling

Repo-root helper scripts:

- `./check` — validate every recipe against the package rules above. Exits
  non-zero on any violation.
- `./dco [<range>]` — verify every non-merge commit in `<range>` (default
  `origin/master..HEAD`) carries a `Signed-off-by:` trailer matching its
  author. Homebaked DCO check; CI runs it on every push and PR.
- `./clean` — remove all git-ignored build debris (`pkg/`, `src/`, fetched
  sources, built packages) repo-wide, after a confirmation prompt.
- `./bump [pkg...]` — refresh packages to the latest upstream state, by tier:
  `*-rel` runs `pkgctl version upgrade` + `updpkgsums`; `*-git` re-clones and
  reruns `pkgver()` (no hashes to bump — git's ref is the integrity check).
  Both regenerate `.SRCINFO`. With no args, refreshes them all.

Packaging you'll want: `nvchecker`, `devtools`, `base-devel` and `pacman-contrib`.

## CI

GitHub Actions (`.github/workflows/check.yml`) runs two jobs on **every branch
push and every pull request**: `policy` (`bash check`) and `dco` (`bash dco`).
A branch that violates any package rule, or carries a commit without a matching
`Signed-off-by:` trailer, fails CI and cannot be merged into `master`.

---
