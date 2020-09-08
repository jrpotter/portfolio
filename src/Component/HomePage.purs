module Component.HomePage
( component
) where

import Data.Symbol (SProxy(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Prelude

import Component.NavBar as NavBar

-- =============================================================================
-- Slots
-- =============================================================================

type Slots = ( navbar :: forall query. H.Slot query Void Int )

navbarProxy = SProxy :: SProxy "navbar"

-- =============================================================================
-- Component
-- =============================================================================

type State = Unit

component :: forall query input output m. MonadAff m
          => H.Component HH.HTML query input output m
component = H.mkComponent
  { initialState: \_ -> unit
  , render
  , eval: H.mkEval H.defaultEval
  }

render :: forall m. MonadAff m => State -> H.ComponentHTML Unit Slots m
render state = HH.div_
  [ HH.slot navbarProxy 0 NavBar.component absurd absurd
  , HH.div_ [ HH.text "HI" ]
  ]
