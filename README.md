# portfolio

## Backend

Our server is very small. As of now it consists of a single `Main.hs` file
powered by [Scotty](https://github.com/scotty-web/scotty) which exposes the
following endpoints:

- `/api/post/:slug`
  - Allows retrieving the details of a single post. Used to pull information,
    such as title, date created, etc., of a single post.
- `/api/posts/`
  - Allows retrieving details of all posts currently written.
- `/post/:slug/`
  - Allow pulling in an HTML file which boots any custom JS for a given post.

Because of the simplicity of our site, we avoid dealing with any production
ready database in favor of SQLite. Instead of modifying our SQL with Haskell
(I used to play around with the great Opaleye library but its a lot of
machinery), here we favor only committing idempotent SQL operations on startup.

Migrations, updates to our table, etc. will be done through the SQLite CLI with
the only record being the committed `.db` instance. I may eventually look into
instead committing exported CSV files describing the Schema and contents but
this seems like a bit more work than necessary as of now.

To access the database, you can run the following from the root directory:

```
nix-shell
sqlite3 db/portfolio.db
sqlite3 db/portfolio.db < db/posts.sql
```

From there, entering a new Post value may look like:
```
INSERT INTO Post
( title
, description
, created_at
, updated_at
, slug
) VALUES
( 'Spot It'
, 'This is about the board game Spot It.'
, DATETIME('now')
, DATETIME('now')
, 'spot-it'
);
```

We use Nix for reproducibility of builds and NixOps for deployment to AWS. Any
deployment scripts included here will be focused around the Nix toolchain as a
result. To build the server locally, run the following:

```
# Install Nix which will be used to include fixed versions of our Haskell
# packages.
curl -L https://nixos.org/nix/install | sh
# Update our nixpkgs config since the IHaskell library we use is marked broken.
mkdir -p ~/.config/nixpkgs
echo '{ allowBroken: true; }' >> ~/.config/nixpkgs/config.nix
# Build our backend using Nix to pull in dependencies listed in our cabal file.
nix-build
# Lastly run our backend and view served files on the exposed port.
result/bin/portfolio
```

## Frontend

For the web side of things, we use the [Halogen](https://github.com/purescript-halogen/purescript-halogen)
library, powered by Purescript. It is a component-based system like React or
Vue but for the Purescript language. Halogen is generally used to create an SPA
but to avoid loading in javascript globally across all posts, we use Webpack's
experimental feature of multiple entrypoint to (effectively) break up each post
into their own SPA.

This does mean as of now we lose some caching benefits, but this can be
corrected in the future by chunking our files into what is actually common
across posts or not.

```
# Install NVM to allow different versions of NPM as needed. Specified below is
# the latest version this project has been tested against.
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
nvm install 12.14.1
# Install purescript dependencies.
npm install -g purescript
npm install -g spago
# Run custom NPM script to build the requisite files to be served by our
# backend.
npm run build [test|prod]
```

## Notebook

We also use [IHaskell](https://github.com/gibiansky/IHaskell) and the Juptyer
web viewer to run notebooks for any posts we want some level of interactive
coding with. Getting this running just requires the following:

```
# Run our shell from the root directory of this project.
nix-shell
# Run a binary copied over from the IHaskell nix project. This will load a
# Jupyter lab that is able to run both Python and Haskell.
ihaskell-lab
```

Afterward the notebook can be embedded in any webpage via an iframe and the
[Jupyter NBViewer](https://nbviewer.jupyter.org/).
