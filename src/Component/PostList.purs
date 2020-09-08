module Component.PostList
( component
) where

import Data.Symbol (SProxy(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Prelude

import Component.PostCard as PostCard

-- =============================================================================
-- Slots
-- =============================================================================

type Slots = ( post :: forall query. H.Slot query Void Int )

postProxy = SProxy :: SProxy "post"

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
  [ HH.slot postProxy 0 PostCard.component absurd absurd ]
