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
