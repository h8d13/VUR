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
   install a published release artifact. No other suffix is allowed.
2. **No `.install` scriptlets** no `install=` line and no `*.install` file.
   `*.install` is not on the allowlist, so it cannot even be committed.
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
- `./clean` — remove all git-ignored build debris (`pkg/`, `src/`, fetched
  sources, built packages) repo-wide, after a confirmation prompt.
- `./bumprels [pkg...]` — for every release-tracked package (one with a
  `.nvchecker.toml`), bump `pkgver` to the latest upstream tag, refresh
  checksums, and regenerate `.SRCINFO`. With no args, bumps them all.

Packaging you'll want: `nvchecker`, `devtools`, `base-devel` and `pacman-contrib`.

## CI

GitHub Actions (`.github/workflows/check.yml`) runs `bash check` on **every
branch push and every pull request**. A branch that violates any package rule
fails CI and cannot be merged into `master`.

---
