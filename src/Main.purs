module Main where

import Control.Monad.Error.Class (throwError)
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Exception (error)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Prelude
import Web.DOM.ParentNode (QuerySelector(..))
import Web.HTML.HTMLElement (HTMLElement)

import Component.NavBar as NavBar

main :: Effect Unit
main = HA.runHalogenAff do
  app <- awaitApp
  runUI NavBar.component unit app

awaitApp :: Aff HTMLElement
awaitApp = do
  HA.awaitLoad
  app <- HA.selectElement (QuerySelector "#app")
  maybe (throwError (error "Could not find app")) pure app
