module Component.PostHeader
( component
) where

import Data.Formatter.DateTime (FormatterCommand(..), format)
import Data.List.Types ((:), List(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Properties as HP
import Model.Post as P
import Prelude

-- =============================================================================
-- Types
-- =============================================================================

type Input = P.Post

type State = P.Post

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
render state = HH.div_
  [ HH.a
    [ HP.class_ (ClassName "post-title")
    , HP.href $ "/post/" <> state.slug <> "/"
    ]
    [ HH.h2_ [ HH.text state.title ] ]
  , HH.span
    [ HP.class_ (ClassName "post-date") ]
    [ HH.text $ format
      ( MonthFull
      : Placeholder " "
      : DayOfMonthTwoDigits
      : Placeholder " "
      : YearFull
      : Nil
      ) state.updatedAt
    ]
  ]
