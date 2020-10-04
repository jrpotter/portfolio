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
import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)
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

render :: forall m. MonadAff m => State -> H.ComponentHTML Action Slots m
render Nothing = HH.slot navBarProxy 0 NB.component absurd absurd
render (Just state) = HH.div_
  [ HH.slot navBarProxy 0 NB.component absurd absurd
  , HH.div
    [ HP.class_ (ClassName "post-body") ]
    [ HH.slot postHeaderProxy 1 PH.component state absurd
    -- -------------------------------------------------------------------------
    -- Introduction
    -- -------------------------------------------------------------------------
    , HH.h2_ [ HH.text "Introduction" ]
    , HH.p_ 
      [ HH.text """
        Spot it! is a party game consisting of 55 cards, each with a variety of
        different symbols, consisting of just a single matching symbol between
        any pair. For example, there exists just one common symbol on each pair
        of cards below:
        """
      ]
    , HH.div [ HP.id_ "intro-cards" ] (map introCard [1, 2, 3])
    , HH.p_
      [ HH.text """
        Between cards (1) and (2) we see the orangish treble clef; between cards
        (2) and (3) we see the word "ART"; between cards (1) and (3) we see the
        water drop. Between each of these pairs, there will be no other match.
        This holds true across all 55 cards included in Spot it! and how this
        holds true as well as how we can automate finding these matches will be
        the topic of this post.
        """
      ]
    ]
  ]

postRequest :: AX.Request DA.Json
postRequest = AX.defaultRequest
  { url = "/api/post/spot-it"
  , method = Left GET
  , responseFormat = ResponseFormat.json
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
      Right post -> H.put (Just post)


-- =============================================================================
-- Introduction
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
