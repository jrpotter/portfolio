# Portfolio

This is a reflex-frp application used for my personal portfolio.

## Organization

Our project uses GHCJS and as such is organized in three subprojects. First, we
have the `backend`, which we use traditional GHC to build. Second, we have the
`frontend`, which has the GHCJS code we want to convert into javascript. Lastly
we have the `common` project which we use to share code between the `backend`
and `frontend`.

We use `nix` to perform our builds and `cabal` for incremental building (since
`nix` does not support such a notion).

## Nix

Before building, you should examine the `nix` subdirectory. Here you'll see the
`default.nix` file and `reflex-platform.nix` file. The latter is a nixification
of the `reflex-platform` project, with
[instructions](https://github.com/reflex-frp/reflex-platform/blob/develop/docs/project-development.md)
we mostly followed to bootstrap this project.

## Building

Because `nix` does not support incremental building, we use the `shells` field
to setup `nix-shell` sandboxes that `cabal` can use to build the projects. The
`cabal.project` files are used to configure how `cabal` builds our local
project.

To build with GHC, we run:

```
nix-shell nix/default.nix -A shells.ghc
cabal build
```

and likewise, to run with GHCJS, we run

```
nix-shell nix/default.nix -A shells.ghcjs
cabal \
  --project-file=cabal-ghcjs.project \
  --builddir=dist-ghcjs \
  build
```