# Portfolio

Functional programming as a general programming paradigm is very powerful and
should be a tool more people are willing to grab. Unfortunately, despite what
people may claim to the contrary, it is often unwieldy and confusing. I find
myself coming back to Haskell in particular every couple of years out of
curiousity and the desire for a better tool in my general day-to-day work, but
find that I've forgotten a lot of what I had learned in the interim.

This project is meant to serve as an excuse for me to keep coming back and
learning more in the functional ecosystem over time, as opposed to in sharp
bursts when other work that has occupied my time slows. A blog seems
like a fitting project for this purpose since I imagine what capabilities I want
my backend/frontend to exhibit depend on what I'm interested in posting about,
forcing myself to continue learning.

This is not my first time trying to start up a portfolio site and by no means do
I have enough confidence to say this time it'll stick. I'd like it to though, so
here goes nothing.

# Organization

The `backend` subproject uses [servant](https://www.servant.dev/) to serve
content. The `frontend` project uses [reflex-frp](https://reflex-frp.org/) (and
GHCJS under the hood) to compile Haskell to Javascript for SPA purposes. The
`common` subproject will include code I look to share between the backend and
frontend. Note the organization here is inline with the recommendations included
in the `reflex-frp/reflex-platform`
[instructions](https://github.com/reflex-frp/reflex-platform/blob/develop/docs/project-development.md).

We use nix for package management but cabal within a `nix-shell` for incremental
building. Fortunately, `reflex-frp` includes a helpful template for using `nix`
in `reflex` projects. Further details are included in the `nix/default.nix`
file.

To develop locally, run the following:

```
nix-shell nix/default.nix -A shells.ghc
cabal build
```

To build for deployment, we leave the `nix-shell` and `nix-build` directly:

```
nix-build nix/default.nix -o dist-backend -A ghc.backend
nix-build nix/default.nix -o dist-frontend -A ghcjs.frontend
```

This compiles a standard Haskell binary in the case of the backend and a full
GHC-runtime compiled into Javascript in the case of the frontend.

# Docker

When we actually aim to deploy everything out, we use `nix`'s `dockerTools`
method to build our `docker` images. We use `nix` to build our images for a
couple of reasons:

1. Only one layer exists in the resulting image. `nix` builds everything from
   scratch and requires no layering to get something working.
1. Only required dependencies exist in the resulting image. While disk usage
   isn't so big a deal in today's times, it's still nice to prune this down as
   much as possible.
1. This methodology is truly reproducible. We've pinned all versions, can pin
   our version of `nix`, and can ensure that this build will always produce the
   exact same image.

To build and load locally, run the following:

```
nix-build nix/docker.nix
docker load < result
docker run --network=host -e PGHOST=127.0.0.1 -e ... <image>
```
