module Component.Notebook
( component
) where

import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Properties as HP
import Prelude

-- =============================================================================
-- Types
-- =============================================================================

type Input = String

type State = String

type Action = Unit

type Slots = ()

-- =============================================================================
-- Component
-- =============================================================================

component :: forall query output m. MonadAff m
          => H.Component HH.HTML query Input output m
component = H.mkComponent
  { initialState: identity
  , render
  , eval: H.mkEval H.defaultEval
  }

render :: forall m. MonadAff m => State -> H.ComponentHTML Action Slots m
render state = HH.iframe
  [ HP.class_ (ClassName "notebook")
  , HP.src $ "/notebooks/" <> state <> ".html"
  ]
