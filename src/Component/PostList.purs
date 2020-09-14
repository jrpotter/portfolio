module Component.PostList
( component
) where

import Affjax as AX
import Affjax.ResponseFormat as ResponseFormat
import Component.PostCard as PC
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)
import Data.Argonaut as DA
import Data.DateTime (DateTime)
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.JSDate as JS
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Data.Traversable (for)
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (log)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Prelude

-- =============================================================================
-- Model
-- =============================================================================

-- | A raw representation of our JSON response.
--
-- It is expected this method is processed by a parser to convert datetime
-- strings to a `DateTime` instance. We are required to perform this casting
-- because `DateTime` does not have a `DecodeJson` instance declaration.
newtype PostCardR = PostCardR
  { title :: String
  , description :: String
  , createdAt :: String
  , updatedAt :: String
  , slug :: String
  }

instance decodePostCardR :: DA.DecodeJson PostCardR where
  decodeJson json = do
   obj <- DA.decodeJson json
   title <- DA.getField obj "title"
   description <- DA.getField obj "description"
   createdAt <- DA.getField obj "created_at"
   updatedAt <- DA.getField obj "updated_at"
   slug <- DA.getField obj "slug"
   pure $ PostCardR { title, description, createdAt, updatedAt, slug }

-- =============================================================================
-- Slots
-- =============================================================================

type Slots = ( post :: forall query. H.Slot query Void Int )

postProxy = SProxy :: SProxy "post"

-- =============================================================================
-- Component
-- =============================================================================

type State = Array PC.PostCard

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
  map (\p -> HH.slot postProxy 0 PC.component p absurd) state

-- =============================================================================
-- Action
-- =============================================================================

data Action = Initialize

mapLeft :: forall a b c. (a -> b) -> Either a c -> Either b c
mapLeft f (Left e) = Left $ f e
mapLeft f (Right e) = Right e

-- | Modifying of the `request` method provided by Affjax.
--
-- For simplicity we convert the error type to a string so we can rope all of
-- our exception-like monads together.
request' :: forall a. AX.Request a -> Aff (Either String (AX.Response a))
request' req = do
  result <- AX.request req
  pure $ mapLeft AX.printError result

-- | Modifying of the `decodeJson` method provided by Argonaut.
--
-- For simplicity we convert the error type to a string so we can rope all of
-- our exception-like monads together.
decodeJson' :: forall a. DA.DecodeJson a => DA.Json -> Either String a
decodeJson' json =
  let result = DA.decodeJson json in mapLeft DA.printJsonDecodeError result

-- | Take in a text datetime and convert it to a real implementation.
parse :: forall m. MonadAff m => String -> ExceptT String m DateTime
parse dt = do
  parsed <- H.liftEffect $ JS.parse dt
  ExceptT $ pure $ case JS.toDateTime parsed of
    Nothing -> Left "Could not parse datetime."
    Just dt' -> Right dt'

-- | Utility method to try and convert a raw `PostCard` to a real one.
readRaw :: forall m. MonadAff m => PostCardR -> ExceptT String m PC.PostCard
readRaw (PostCardR { title, description, createdAt, updatedAt, slug }) = do
  a <- parse createdAt
  b <- parse updatedAt
  let rec = { title, description, createdAt: a, updatedAt: b, slug }
  ExceptT $ pure $ Right rec

postListRequest :: AX.Request DA.Json
postListRequest = AX.defaultRequest
  { url = "/api/posts/"
  , method = Left GET
  , responseFormat = ResponseFormat.json
  }

handleAction :: forall output m. MonadAff m
             => Action -> H.HalogenM State Action Slots output m Unit
handleAction Initialize = do
  result <- runExceptT do
     response <- ExceptT $ H.liftAff $ request' postListRequest
     decoded <- ExceptT $ pure $ decodeJson' response.body
     for decoded readRaw
  case result of
      Left err -> log $ "Could not get posts: " <> err
      Right pc -> H.put pc
