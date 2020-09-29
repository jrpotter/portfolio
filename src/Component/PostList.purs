module Component.PostList
( component
) where

import Affjax as AX
import Affjax.ResponseFormat as ResponseFormat
import Component.PostPreview as PP
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)
import Data.Argonaut as DA
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Data.Traversable (for)
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (log)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Model.Post as P
import Network.Request (decodeJson', request')
import Prelude

-- =============================================================================
-- Types
-- =============================================================================

type State = Array P.Post

data Action = Initialize

type Slots = ( post :: forall query. H.Slot query Void Int )

postProxy = SProxy :: SProxy "post"

-- =============================================================================
-- Component
-- =============================================================================

component :: forall query input output m. MonadAff m
          => H.Component HH.HTML query input output m
component = H.mkComponent
  { initialState: \_ -> []
  , render
  , eval: H.mkEval $ H.defaultEval
    { handleAction = handleAction
    , initialize = Just Initialize
    }
  }

render :: forall m. MonadAff m => State -> H.ComponentHTML Action Slots m
render state = HH.div [ HP.id_ "post-list" ] $
  map (\p -> HH.slot postProxy 0 PP.component p absurd) state

postListRequest :: AX.Request DA.Json
postListRequest = AX.defaultRequest
  { url = "/api/posts"
  , method = Left GET
  , responseFormat = ResponseFormat.json
  }

handleAction :: forall output m. MonadAff m
             => Action -> H.HalogenM State Action Slots output m Unit
handleAction Initialize = do
  result <- runExceptT do
     response <- ExceptT $ H.liftAff $ request' postListRequest
     decoded <- ExceptT $ pure $ decodeJson' response.body
     for decoded P.readRaw
  case result of
      Left err -> log $ "Could not get posts: " <> err
      Right posts -> H.put posts
