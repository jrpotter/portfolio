module Component.NavBar
( component
) where

import Control.Monad.Maybe.Trans (MaybeT(..), runMaybeT)
import Data.Array ((..))
import Data.Int (floor, toNumber)
import Data.Maybe (Maybe(..))
import Data.Traversable (for)
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Random (random)
import Graphics.Canvas as GC
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Query.EventSource (eventListenerEventSource)
import Math ((%))
import Prelude
import Web.DOM.Element (clientHeight, clientWidth)
import Web.DOM.ParentNode (QuerySelector(..))
import Web.Event.Event (EventType(..))
import Web.HTML (window)
import Web.HTML.HTMLElement (toElement)
import Web.HTML.Location (assign)
import Web.HTML.Window (location, toEventTarget)

-- =============================================================================
-- Types
-- =============================================================================

type State =
  { -- | Width of our navigation div.
    navbarWidth :: Int
  , -- | Height of our navigation div.
    navbarHeight :: Int
  }

data Action = Initialize | Randomize | Redirect

type Slots = ()

-- =============================================================================
-- Constants
-- =============================================================================

navbarId :: String
navbarId = "navbar"

canvasId :: String
canvasId = "navbar-canvas"

gridDimen :: Int
gridDimen = 12

gridStrokeColor :: String
gridStrokeColor = "#298794"

gridFillColor :: String
gridFillColor = "#6CBCC8"

-- =============================================================================
-- Component
-- =============================================================================

component :: forall query input output m. MonadAff m
          => H.Component HH.HTML query input output m
component = H.mkComponent
  { initialState: \_ -> { navbarWidth: 0, navbarHeight: 0 }
  , render
  , eval: H.mkEval $ H.defaultEval
    { handleAction = handleAction
    , initialize = Just Initialize
    }
  }

render :: forall m. State -> H.ComponentHTML Action Slots m
render state = HH.div
  [ HP.id_ navbarId ]
  [ HH.canvas
    [ HP.id_ canvasId
    , HP.height state.navbarHeight
    , HP.width state.navbarWidth
    ]
  , HH.div
    [ HP.id_ "logo-wrapper", HE.onClick \_ -> Just Redirect ]
    [ HH.h1_ [ HH.text "FuzzyKayak" ]
    , HH.img
      [ HP.src "https://avatars2.githubusercontent.com/u/3267697?s=300&v=4" ]
    ]
  , HH.div
    [ HP.id_ "social-wrapper" ]
    [ HH.a
      [ HP.href "https://www.github.com/jrpotter/"
      , HP.target "_blank"
      ]
      [ HH.i
        [ HP.class_ (ClassName "fab fa-github fa-2x") ]
        [ ]
      ]
    ]
  ]

-- =============================================================================
-- Canvas
-- =============================================================================

gridLines :: Int -> Array Int
gridLines n = map (\g -> g * gridDimen) (1 .. (n / gridDimen))

colorRect :: GC.Context2D -> Number -> Number -> Effect Unit
colorRect ctx w h = do
  uniform <- random
  let d = toNumber gridDimen
  let pos = uniform * w * h
  let row = pos / w
  let col = pos % w
  let r = { x: col - (col % d), y: row - (row % d), width: d, height: d }
  GC.fillPath ctx $ GC.rect ctx r

strokeRect :: GC.Context2D -> GC.Rectangle -> Effect Unit
strokeRect ctx r = GC.strokePath ctx $ do
  GC.moveTo ctx r.x r.y
  GC.lineTo ctx r.width r.height
  GC.closePath ctx

-- =============================================================================
-- Action
-- =============================================================================

handleAction :: forall output m. MonadAff m
             => Action -> H.HalogenM State Action Slots output m Unit

handleAction Initialize = do
  window' <- H.liftEffect window
  H.subscribe' \sid -> eventListenerEventSource
    (EventType "resize") (toEventTarget window') (\_ -> Just Randomize)
  handleAction Randomize

handleAction Randomize = void $ runMaybeT do
  let query = QuerySelector $ "#" <> navbarId
  navbar <- MaybeT $ H.liftAff $ HA.selectElement query
  canvas <- MaybeT $ H.liftEffect $ GC.getCanvasElementById canvasId

  height <- H.liftEffect $ clientHeight $ toElement navbar
  let height' = floor height
  width <- H.liftEffect $ clientWidth $ toElement navbar
  let width' = floor width
  H.modify_ _ { navbarHeight = height', navbarWidth = width' }

  H.liftEffect $ do
    -- Can now clear our canvas context and re-draw our state.
    ctx <- GC.getContext2D canvas
    GC.clearRect ctx { x: 0.0, y: 0.0, width, height }
    GC.setStrokeStyle ctx gridStrokeColor
    let gx = map toNumber $ gridLines width'
    let gy = map toNumber $ gridLines height'
    void $ for gx (\x -> strokeRect ctx { x, y: 0.0, width: x, height })
    void $ for gy (\y -> strokeRect ctx { x: 0.0, y, width, height: y })
    -- Randomly decide which squares we want to color in our grid.
    GC.setFillStyle ctx gridFillColor
    void $ for (1 .. 80) (\_ -> colorRect ctx width height)

handleAction Redirect = H.liftEffect $ do
  w <- window
  loc <- location w
  assign "/" loc
