module Component.PostCard
( component
) where

import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Properties as HP
import Prelude

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

render :: forall m. State -> H.ComponentHTML Unit () m
render state = HH.div
  [ HP.class_ (ClassName "post-card") ]
  [ HH.h2
    [ HP.class_ (ClassName "post-title") ]
    [ HH.text "Post sample" ]
  , HH.p
    [ HP.class_ (ClassName "post-preview") ]
    [ HH.text "Post context" ]
  , HH.ul_
    [ HH.li [ HP.class_ (ClassName "tag-math") ] [ HH.text "math" ]
    , HH.li [ HP.class_ (ClassName "tag-math") ] [ HH.text "math" ]
    ]
  ]
