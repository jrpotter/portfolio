{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "portfolio"
, dependencies =
  [ "affjax"
  , "argonaut"
  , "assert"
  , "canvas"
  , "console"
  , "datetime"
  , "effect"
  , "halogen"
  , "js-date"
  , "lists"
  , "psci-support"
  , "random"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
