module Component.CodeBlock
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

type Input =
  { -- | The code that will be placed in the block.
    code :: String
  , -- | The language the code is written in.
    lang :: String
  }

type State = Input

data Action = Initialize

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
render state = HH.pre_
  [ HH.code
    [ HP.class_ (ClassName $ "lang-" <> state.lang) ]
    [ HH.text state.code ]
  ]
