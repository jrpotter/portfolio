module Main where

import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Prelude

import Component.PostList as PostList

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  runUI PostList.component unit body
