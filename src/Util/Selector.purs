module Util.Selector
( awaitApp
) where

import Control.Monad.Error.Class (throwError)
import Data.Maybe (maybe)
import Effect.Aff (Aff)
import Effect.Exception (error)
import Halogen.Aff as HA
import Prelude
import Web.DOM.ParentNode (QuerySelector(..))
import Web.HTML.HTMLElement (HTMLElement)

awaitApp :: Aff HTMLElement
awaitApp = do
  HA.awaitLoad
  app <- HA.selectElement (QuerySelector "#app")
  maybe (throwError (error "Could not find app")) pure app
