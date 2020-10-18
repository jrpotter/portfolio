module Component.PostPreview
( component
) where

import Component.PostHeader as PH
import Data.Symbol (SProxy(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Properties as HP
import Html.Renderer.Halogen as RH
import Model.Post as P
import Prelude

-- =============================================================================
-- Types
-- =============================================================================

type Input = P.Post

type State = P.Post

type Action = Unit

type Slots = ( postHeader :: forall query. H.Slot query Void Unit )

postHeaderProxy = SProxy :: SProxy "postHeader"

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
render state = HH.div
  [ HP.class_ (ClassName "post-preview") ]
  [ HH.slot postHeaderProxy unit PH.component state absurd
  , HH.p
    [ HP.class_ (ClassName "post-description") ]
    [ RH.render_ state.description ]
  ]
