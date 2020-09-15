module Page.Index
( page
) where

import Component.Index (component)
import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Prelude
import Util.Selector (awaitApp)

page :: Effect Unit
page = HA.runHalogenAff do
  app <- awaitApp
  runUI component unit app
