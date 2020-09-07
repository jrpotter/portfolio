module Component.NavBar
( component
) where

import Data.Maybe (Maybe(..))
import Effect.Class (class MonadEffect)
import Graphics.Canvas as GC
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events (onResize)
import Halogen.HTML.Properties as HP
import Halogen.Query.EventSource (eventListenerEventSource)
import Prelude
import Web.HTML.HTMLDocument as HTMLDocument

type State = Unit

data Action = Initialize | Generate

component :: forall query input output m. MonadEffect m
          => H.Component HH.HTML query input output m
component = H.mkComponent
  { initialState
  , render
  , eval: H.mkEval $ H.defaultEval
    { handleAction = handleAction
    , initialize = Just Initialize
    }
  }

initialState :: forall input. input -> State
initialState _ = unit

render :: forall m. State -> H.ComponentHTML Action () m
render state = HH.div
  [ HP.id_ "navbar" ]
  [ HH.canvas
    [ HP.id_ "navbar-canvas" ]
  , HH.h1_
    [ HH.text "FuzzyKayak" ]
  , HH.img
    [ HP.src "https://avatars2.githubusercontent.com/u/3267697?s=180&v=4" ]
  ]

handleAction :: forall output m. MonadEffect m
             => Action -> H.HalogenM State Action () output m Unit
handleAction Initialize = do
  canvas <- H.liftEffect $ GC.getCanvasElementById "navbar-canvas"
  case canvas of
    Just x -> H.liftEffect $ do
       ctx <- GC.getContext2D x
       GC.setFillStyle ctx "#00F"
       GC.fillPath ctx $ GC.rect ctx
         { x: 250.0
         , y: 250.0
         , width: 100.0
         , height: 100.0
         }
    _ -> pure unit
handleAction _ = pure unit
