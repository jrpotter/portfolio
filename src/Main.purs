module Main where

import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Prelude

import Component.NavBar as NavBar

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  runUI NavBar.component unit body
