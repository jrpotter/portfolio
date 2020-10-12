module Component.FAB.Notebook
( component
) where

import Component.Notebook as N
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Prelude

-- =============================================================================
-- Types
-- =============================================================================

type Input = String

type State =
  { -- | The name of the notebook.
    name :: String
  , -- | Track whether our notebook is visible or not.
    visible :: Boolean
  }

data Action = Toggle

type Slots = ( notebook :: forall query. H.Slot query Void Int )

notebookProxy = SProxy :: SProxy "notebook"

-- =============================================================================
-- Component
-- =============================================================================

component :: forall query output m. MonadAff m
          => H.Component HH.HTML query Input output m
component = H.mkComponent
  { initialState: \name -> { name, visible: false }
  , render
  , eval: H.mkEval $ H.defaultEval { handleAction = handleAction }
  }

render :: forall m. MonadAff m => State -> H.ComponentHTML Action Slots m
render state =
  HH.div
  [ HP.id_ "fab-notebook"
  , HE.onClick \_ -> Just Toggle
  ]
  [ HH.div
    [ HP.class_ (ClassName "fab-icon") ]
    [ HH.i [ HP.class_ (ClassName "fas fa-book-open fa-lg") ] [ ]
    ]
  , HH.div
    [ HP.class_ (ClassName if state.visible then "" else "invisible") ]
    [ HH.slot notebookProxy 2 N.component state.name absurd
    ]
  ]

handleAction :: forall output m. MonadAff m
             => Action -> H.HalogenM State Action Slots output m Unit
handleAction Toggle = H.modify_ \s -> s { visible = not s.visible }
