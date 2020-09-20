module Component.PostCard
( PostCard
, component
) where

import Data.DateTime (DateTime)
import Data.Formatter.DateTime (FormatterCommand(..), format)
import Data.List.Types ((:), List(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Properties as HP
import Html.Renderer.Halogen as RH
import Prelude

-- =============================================================================
-- Model
-- =============================================================================

type PostCard =
  { title :: String
  , description :: String
  , createdAt :: DateTime
  , updatedAt :: DateTime
  , slug :: String
  }

-- =============================================================================
-- Component
-- =============================================================================

type Input = PostCard

type State = PostCard

component :: forall query output m. MonadAff m
          => H.Component HH.HTML query Input output m
component = H.mkComponent
  { initialState: identity
  , render
  , eval: H.mkEval H.defaultEval
  }

render :: forall action m. State -> H.ComponentHTML Unit action m
render state = HH.div
  [ HP.class_ (ClassName "post-card") ]
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
  , HH.p
    [ HP.class_ (ClassName "post-description") ]
    [ RH.render_ state.description ]
  ]
