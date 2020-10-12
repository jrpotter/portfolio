{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module Main
( main
) where

import Control.Applicative ((<*>), Applicative)
import Control.Monad (Monad, return)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Control.Monad.Reader (MonadReader, ReaderT, ask, runReaderT)
import Data.Aeson ((.=), ToJSON, toJSON)
import Data.Char (toLower, toUpper)
import Data.Default.Class (def)
import Data.Either (Either(..))
import Data.Function (($))
import Data.Functor ((<$>), Functor, fmap)
import Data.Int (Int)
import Data.List ((++))
import Data.Maybe (Maybe(..), fromJust, listToMaybe)
import Data.String (String)
import Data.Text.Lazy (Text, fromStrict)
import Data.Time.Clock (UTCTime)
import Network.HTTP.Types.Status (status404)
import Network.Wai.Middleware.Static ((>->))
import Prelude (error)
import System.IO (IO, putStrLn)
import Text.Mustache ((~>), Template, ToMustache, automaticCompile, substitute)
import Text.Show (show)
import Web.Scotty.Trans (ActionT, ScottyT, scottyOptsT)

import qualified Data.Aeson as Aeson
import qualified Database.SQLite.Simple as Simple
import qualified Network.Wai.Middleware.Static as Static
import qualified Text.Mustache as Mustache
import qualified Web.Scotty.Trans as Scotty

-- =============================================================================
-- Config
-- =============================================================================

data Config = Config { _configConnection :: Simple.Connection }

newtype ConfigM a = ConfigM
  { runConfigM :: ReaderT Config IO a }
  deriving (Applicative, Functor, Monad, MonadIO, MonadReader Config)

-- =============================================================================
-- Database
-- =============================================================================

databaseName :: String
databaseName = "db/portfolio.db"

data PostField = PostField
  Int      -- ^ id
  Text     -- ^ title
  Text     -- ^ description
  UTCTime  -- ^ created_at
  UTCTime  -- ^ updated_at
  Text     -- ^ slug

instance Simple.FromRow PostField where
  fromRow = PostField
    <$> Simple.field
    <*> Simple.field
    <*> Simple.field
    <*> Simple.field
    <*> Simple.field
    <*> Simple.field

instance ToJSON PostField where
  toJSON (PostField a b c d e f) = Aeson.object
    [ "id" .= a
    , "title" .= b
    , "description" .= c
    , "created_at" .= d
    , "updated_at" .= e
    , "slug" .= f
    ]

initialize :: (MonadReader Config m, MonadIO m) => m ()
initialize = do
  config <- ask
  let conn = _configConnection config
  liftIO $ Simple.execute_ conn "     \
    \ CREATE TABLE IF NOT EXISTS Post \
    \ ( id INTEGER PRIMARY KEY        \
    \ , title TEXT                    \
    \ , description TEXT              \
    \ , created_at TEXT               \
    \ , updated_at TEXT               \
    \ , slug TEXT UNIQUE              \
    \ );                              "

-- =============================================================================
-- Verbs
-- =============================================================================

-- | Specify types here for error message type resolution.
get :: (MonadIO m)
    => Scotty.RoutePattern
    -> Scotty.ActionT Text m ()
    -> Scotty.ScottyT Text m ()
get = Scotty.get

-- =============================================================================
-- Actions
-- =============================================================================

getPost :: (MonadReader Config m, MonadIO m) => String -> m (Maybe PostField)
getPost slug = do
  config <- ask
  let conn = _configConnection config
  results <- liftIO $ query conn slug
  return $ listToMaybe results
  where
    query :: Simple.Connection -> String -> IO [PostField]
    query c slug =
      Simple.query c "SELECT * FROM POST WHERE slug = ?" (Simple.Only slug)

getPostList :: (MonadReader Config m, MonadIO m) => m [PostField]
getPostList = do
  config <- ask
  let conn = _configConnection config
  liftIO $ query conn
  where
    query :: Simple.Connection -> IO [PostField]
    query c = Simple.query_ c "SELECT * FROM Post ORDER BY created_at DESC"

-- =============================================================================
-- Server
-- =============================================================================

newtype Script = Script { runScript :: String }

instance ToMustache Script where
  toMustache (Script value) = Mustache.object ["script" ~> value]

-- | Compile various mustache file.
--
-- Should avoid using this in any dynamic sense - compilation is slow.
loadHTML :: String -> IO (Maybe Template)
loadHTML filename = do
  compiled <- automaticCompile [".", "./dist"] filename
  return $ case compiled of
    Left err -> Nothing
    Right template -> Just template

main :: IO ()
main = do
  -- Because this would mean our site wouldn't load, try loading our index file
  -- before we bother starting up the server at all. Force unwrap to raise an
  -- error if it cannot be found.
  indexTemplate <- loadHTML "index.html"
  let index = fromJust indexTemplate
  -- Initialize our database before running the Scotty app to avoid this
  -- being hit everytime we process an action.
  conn <- Simple.open databaseName
  let config = Config { _configConnection = conn }
  runReaderT initialize config
  -- Allow passing in the config throughout our various Scotty actions. Example
  -- pulled from:
  -- https://github.com/scotty-web/scotty/blob/master/examples/reader.hs
  scottyOptsT def (\m -> runReaderT (runConfigM m) config) $ do
    Scotty.middleware $ Static.staticPolicyWithOptions
      Static.defaultOptions $ Static.addBase "dist"
    -- Retrieve HTML of our index page.
    get "" $ do
      Scotty.html $ fromStrict $ substitute index (Script "index")
    -- Retrieve HTML of a specific post.
    get "/post/:slug" $ do
      slug <- Scotty.param "slug"
      Scotty.html $ fromStrict $ substitute index (Script slug)
    -- Retrieve a list of all posts currently on our blog. This is used within
    -- our homepage.
    get "/api/posts" $ do
      posts <- getPostList
      Scotty.json posts
    -- Retrieve details of a specific post.
    get "/api/post/:slug" $ do
      slug <- Scotty.param "slug"
      post <- getPost slug
      case post of
        Just r -> Scotty.json r
        Nothing -> Scotty.status status404
