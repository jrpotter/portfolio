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
import Data.Aeson ((.=), ToJSON, object, toJSON)
import Data.Default.Class (def)
import Data.Function (($))
import Data.Functor ((<$>), Functor)
import Data.Int (Int)
import Data.Maybe (Maybe(Just))
import Data.String (String)
import Data.Text.Lazy (Text)
import Data.Time.Clock (UTCTime)
import Network.Wai.Middleware.Static ((>->))
import System.IO (IO)
import Web.Scotty.Trans (ActionT, ScottyT, scottyOptsT)

import qualified Database.SQLite.Simple as Simple
import qualified Network.Wai.Middleware.Static as Static
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
  toJSON (PostField a b c d e f) = object
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
-- Actions
-- =============================================================================

getPostList :: (MonadReader Config m, MonadIO m) => m [PostField]
getPostList = do
  config <- ask
  let conn = _configConnection config
  liftIO (Simple.query_ conn "SELECT * FROM Post" :: IO [PostField])

getPostList' :: (MonadReader Config m, MonadIO m) => ActionT Text m ()
getPostList' = do
  posts <- getPostList
  Scotty.json posts

-- =============================================================================
-- Server
-- =============================================================================

policy :: Static.Policy
policy = Static.policy rewrite >-> Static.addBase "dist"
  where
    rewrite :: String -> Maybe String
    rewrite "" = Just "index.html"
    rewrite p = Just p

-- | Allow passing in the config throughout our various Scotty actions.
--
-- Example pulled from:
-- https://github.com/scotty-web/scotty/blob/master/examples/reader.hs
configure :: Config -> ConfigM a -> IO a
configure c m = runReaderT (runConfigM m) c

main :: IO ()
main = do
  conn <- Simple.open databaseName
  let config = Config { _configConnection = conn }
  -- Initialize our database before running the Scotty app to avoid this
  -- being hit everytime we process an action.
  runReaderT initialize config
  scottyOptsT def (configure config) $ do
    let options = Static.defaultOptions
    Scotty.middleware $ Static.staticPolicyWithOptions options policy
    Scotty.get "/api/posts/" getPostList'
