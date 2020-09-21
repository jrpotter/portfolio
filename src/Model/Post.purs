module Model.Post
( Post
, PostR(..)
, readRaw
) where

import Control.Monad.Except.Trans (ExceptT(..))
import Data.Argonaut as DA
import Data.DateTime (DateTime)
import Data.Either (Either(..))
import Data.JSDate as JS
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Prelude

-- =============================================================================
-- Model
-- =============================================================================

-- | Real representation of a post from our backend.
type Post =
  { title :: String
  , description :: String
  , createdAt :: DateTime
  , updatedAt :: DateTime
  , slug :: String
  }

-- =============================================================================
-- JSON
-- =============================================================================

-- | A raw representation of our JSON response.
--
-- It is expected this method is processed by a parser to convert datetime
-- strings to a `DateTime` instance. We are required to perform this casting
-- because `DateTime` does not have a `DecodeJson` instance declaration.
newtype PostR = PostR
  { title :: String
  , description :: String
  , createdAt :: String
  , updatedAt :: String
  , slug :: String
  }

instance decodePostR :: DA.DecodeJson PostR where
  decodeJson json = do
   obj <- DA.decodeJson json
   title <- DA.getField obj "title"
   description <- DA.getField obj "description"
   createdAt <- DA.getField obj "created_at"
   updatedAt <- DA.getField obj "updated_at"
   slug <- DA.getField obj "slug"
   pure $ PostR { title, description, createdAt, updatedAt, slug }

-- =============================================================================
-- Utility
-- =============================================================================

-- | Take in a text datetime and convert it to a real implementation.
parse :: forall m. MonadAff m => String -> ExceptT String m DateTime
parse dt = do
  parsed <- H.liftEffect $ JS.parse dt
  ExceptT $ pure $ case JS.toDateTime parsed of
    Nothing -> Left "Could not parse datetime."
    Just dt' -> Right dt'

-- | Utility method to try and convert a raw `Post` to a real one.
readRaw :: forall m. MonadAff m => PostR -> ExceptT String m Post
readRaw (PostR { title, description, createdAt, updatedAt, slug }) = do
  a <- parse createdAt
  b <- parse updatedAt
  let rec = { title, description, createdAt: a, updatedAt: b, slug }
  ExceptT $ pure $ Right rec
