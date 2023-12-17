# Jekyll Flake Template

This is a template for bootstrapping a [Jekyll](https://jekyllrb.com/)-based
project (version 4.3.2) with the [minima](https://github.com/jekyll/minima)
theme (version 2.5.1). [direnv](https://direnv.net/) can be used to launch a
dev shell upon entering this directory (refer to `.envrc`). Otherwise run via:
```bash
$ nix develop
```
Start the server by running:
```
$ jekyll serve [--watch]
```

## Building

Dependencies are managed using [bundix](https://github.com/nix-community/bundix).
If you make any changes to the `Gemfile`, run the following:
```bash
$ bundix -l
```
This will update the `Gemfile.lock` and `gemset.nix` files. Afterward you can
run:
```bash
$ nix build
```
Note that we need the `.bundle/config` file to workaround issues bundix has with
pre-built, platform-specific gems. Refer to
[PR #68](https://github.com/nix-community/bundix/pull/68) for more details.
