# apc

> `apc` is a wrapper replacement for `pacman`.

only rule is to modify syntax, not modify pacman behavior (too much).

but all args **fall-through to underlying programs.**

```
./apc --help

./apc search --help
```

this second example will just get the `pacman` help.

---

notably my favorite detail:

`./apc install fastfetch-`

which uninstalls note the `-`.

---

## some other details:

all your pacman settings are found in `/etc/pacman.conf`

you may also want to see this wiki page and the section about [hooks](https://wiki.archlinux.org/title/Pacman#Hooks)

they can be useful to automate certain things.

> originally made this for my friend @ModelCitizenPS3, who hates pacman syntax.
> i'm also hoping reading src code could teach some things, since he knows shell very well.

## install:

```shell
git clone <url> <dest>
cd <dest>
```

can be installed to `~/.local/bin`:
```
cp apc ~/.local/bin
```
make sure that is in `$PATH` or install globally with `sudo` to `/usr/bin`

---

## usage:

```
NAME
  apc - Wrapper for common pacman operations
  Requires pacman, pacman-contrib, reflector.

SYNOPSIS
  apc [GLOBAL_OPTIONS] <COMMAND> [OPTIONS]

DESCRIPTION
  apc wraps common pacman operations for system package management.
  Mirrors concepts from Debian (install/uninstall) with pacman syntax.
  Options not listed below are passed through to the underlying tool.
  This means thin syntax shim, not modifying existing behaviors.

  If no command is passed it calls pacman directly.

GLOBAL OPTIONS
  --no-color          Disable colored output

COMMANDS
  search PACKAGE [OPTIONS]        Search for pkgs
      --local, -l                 Search installed pkgs

  install PACKAGE [OPTIONS]       Install a pkg from sync repos
                                  Use "pkg-" to uninstall
  uninstall PACKAGE [OPTIONS]     Uninstall a pkg
      --no-deps                   Don't remove orphaned dependencies

  list [OPTIONS]                  List packages (-Sl)
      --local, -l                 List installed pkgs (-Q)
      --explicit, -e              List explicitly installed pkgs (-Qe)
      --files, -f PKG             List files owned by a pkg (-Ql)
      --why, -w PATH              Which installed pkg owns a file (-Qo)
      --last [N]                  N newest installed/updated pkgs by time (default 20)
      --first [N]                 N oldest installed/updated pkgs by time (default 20)

  info PACKAGE [OPTIONS]          Show detailed pkg information (-Sii)
      --local, -l                 Query installed pkg (-Qii)
      --files, -f PKG             List files a pkg provides (-Fl)
      --why, -w PATH              Which sync pkg provides a file (-F)

  deps PACKAGE [OPTIONS]          Show dependency tree (pactree)

  update [OPTIONS]                Force-sync pkg databases (-Syy)
  upgrade [OPTIONS]               Full system upgrade (-Syu)

  mirrors [OPTIONS]               Update mirrorlist using reflector
      --dry-run                   Print mirrors without saving

  repos [OPTIONS]                 List repos from pacman.conf (enabled/disabled)
      --config FILE               Read an alternate config (default /etc/pacman.conf)

  check [OPTIONS]                 Check for available updates (checkupdates)
  clean [OPTIONS]                 Clean old pkgs from cache (paccache -r)
  orphs [OPTIONS]                 Remove orphaned packages (-Qdtq, then -Rns)

AUTHOR
  (O) Eihdran L. <hadean-eon-dev@proton.me>

SPDX-FileCopyrightText: 2026
SPDX-License-Identifier: 0BSD
```
