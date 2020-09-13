module Component.PostCard
( PostCard
, component
) where

import Data.DateTime (DateTime)
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Properties as HP
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
  [ HH.h2
    [ HP.class_ (ClassName "post-title") ]
    [ HH.text state.title ]
  , HH.p
    [ HP.class_ (ClassName "post-description") ]
    [ HH.text state.description ]
  ]
