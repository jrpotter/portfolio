module Page.SpotIt
( main
) where

import Affjax as AX
import Affjax.ResponseFormat as ResponseFormat
import Component.NavBar as NB
import Component.PostHeader as PH
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)
import Data.Argonaut as DA
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (log)
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)
import MathJax.StartUp (startUp)
import Model.Post as P
import Network.Request (decodeJson', request')
import Prelude
import Util.Selector (awaitApp)

main :: Effect Unit
main = HA.runHalogenAff do
  app <- awaitApp
  runUI component unit app

-- =============================================================================
-- Types
-- =============================================================================

type State = Maybe P.Post

data Action = Initialize

type Slots =
  ( navBar :: forall query. H.Slot query Void Int
  , postHeader :: forall query. H.Slot query Void Int
  )

navBarProxy = SProxy :: SProxy "navBar"

postHeaderProxy = SProxy :: SProxy "postHeader"

-- =============================================================================
-- Component
-- =============================================================================

component :: forall query input output m. MonadAff m
          => H.Component HH.HTML query input output m
component = H.mkComponent
  { initialState: \_ -> Nothing
  , render
  , eval: H.mkEval $ H.defaultEval
    { handleAction = handleAction
    , initialize = Just Initialize
    }
  }

handleAction :: forall output m. MonadAff m
             => Action -> H.HalogenM State Action Slots output m Unit

handleAction Initialize = do
  result <- runExceptT do
     response <- ExceptT $ H.liftAff $ request' postRequest
     decoded <- ExceptT $ pure $ decodeJson' response.body
     P.readRaw decoded
  case result of
      Left err -> log $ "Could not get post: " <> err
      Right post -> do
        H.put $ Just post
        -- Initialize MathJAX after first render request is finished.
        H.liftEffect startUp

-- =============================================================================
-- Render
-- =============================================================================

introCard :: forall w i. Int -> HH.HTML w i
introCard num =
  let path = show num
      prefix = "https://portfolio-static.s3.amazonaws.com/spot-it/cards/"
   in
      HH.div
      [ HP.class_ (ClassName "intro-card") ]
      [ HH.img [ HP.src $ prefix <> path <> ".png" ]
      , HH.p_ [ HH.text $ "(" <> path <> ")" ]
      ]

postContent :: forall m. MonadAff m
            => Maybe P.Post -> H.ComponentHTML Action Slots m
postContent Nothing = HH.div_ []
postContent (Just post) = HH.div_
  [ HH.slot postHeaderProxy 1 PH.component post absurd
  -- -------------------------------------------------------------------------
  -- Introduction
  -- -------------------------------------------------------------------------
  , HH.h2_ [ HH.text "Introduction" ]
  , HH.p_ 
    [ HH.text """
      In light of Covid-19, my girlfriend and I have had to find different
      ways to keep ourselves preoccupied. When we aren't playing Animal
      Crossing or watching Community (or just need a break from screens in
      general), we've been playing a card game called "Spot it!". "Spot it!"
      is a party game consisting of 55 cards, each with a variety of different
      symbols, consisting of just a single matching symbol between any pair.
      For example, there exists just one common symbol on each pair of cards
      below:
      """
    ]
  , HH.div [ HP.id_ "intro-cards" ] (map introCard [1, 2, 3])
  , HH.p_
    [ HH.text """
      Between cards (1) and (2) we see the orangish treble clef; between cards
      (2) and (3) we see the word "ART"; between cards (1) and (3) we see the
      water drop. Furthermore, on careful inspection, we'll see that these are
      the only matches for these pairs. These cards are 3 of the 55 cards
      included in the "Spot it!" game but this property is true between any of
      the \(\binom{55}{2}\) possible pairs. This post will briefly touch on
      the math explaining how this property holds and will then look at how we
      can automate finding these matches.
      """
    ]
  -- -------------------------------------------------------------------------
  -- Mathematics
  -- -------------------------------------------------------------------------
  , HH.h2_ [ HH.text "Mathematics" ]
  ]

render :: forall m. MonadAff m => State -> H.ComponentHTML Action Slots m
render post = HH.div_
  [ HH.slot navBarProxy 0 NB.component absurd absurd
  , HH.div
    [ HP.class_ (ClassName "post-body") ]
    [ postContent post ]
  ]

-- =============================================================================
-- Introduction
-- =============================================================================

postRequest :: AX.Request DA.Json
postRequest = AX.defaultRequest
  { url = "/api/post/spot-it"
  , method = Left GET
  , responseFormat = ResponseFormat.json
  }
