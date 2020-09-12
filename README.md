# portfolio

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
