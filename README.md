# Portfolio

This is a single-page springboard for my various links/projects/services.

## Quickstart

[direnv](https://direnv.net/) can be used to launch a dev shell upon entering
this directory (refer to `.envrc`). Otherwise run via:
```bash
$ nix develop
```

## Language Server

The [typescript-language-server](https://github.com/typescript-language-server/typescript-language-server)
(version 4.1.2) is included in this flake.

## Formatting

Formatting depends on [prettier](https://prettier.io/) (version 3.1.0). A
`pre-commit` hook is included in `.githooks` that can be used to format all
`*.jsx?` and `*.tsx?` files prior to commit. Install via:
```bash
$ git config --local core.hooksPath .githooks/
```
If running [direnv](https://direnv.net/), this hook is installed automatically
when entering the directory.
