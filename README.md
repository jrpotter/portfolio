# portfolio

## Setup

There are a couple of different components combined to get this project working
correctly. In particular, you need to install the following:

```
# Install NVM to allow different versions of NPM as needed. Specified below is
# the latest version this project has been tested against.
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
nvm install 12.14.1
# Install purescript dependencies.
npm install -g purescript
npm install -g spago
# Install Nix which will be used to include fixed versions of our Haskell
# packages.
curl -L https://nixos.org/nix/install | sh
# Update your nix config file to allow broken packages; not all packages are as
# up to date as we'd like.
mkdir -p ~/.config/nixpkgs
echo '{ allowBroken: true; }' >> ~/.config/nixpkgs/config.nix
```

Afterward we use the above toolchains to consolidate everything together. When
first starting up the project you will need to bundle all the frontend files
(javascript, CSS, etc.) so our backend project knows how to serve it correctly.

```
# Include all Node dependencies we need. These are listed in the package.json
# and package-lock.json files.
npm install
# Include all Purescript dependencies we need. These are listed in the
# spago.dhall file.
spago install
# Custom script included in our package.json file.
npm run build
# Build our backend using Nix to pull in dependencies listed in our cabal file.
nix-build
# Lastly run our backend and view served files on the exposed port.
result/bin/portfolio
```

## Database

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
