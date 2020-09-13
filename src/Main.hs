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
import Web.Scotty.Trans (ScottyT, scottyOptsT)

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
  UTCTime  -- ^ created_at
  UTCTime  -- ^ updated_at
  Text     -- ^ slug

instance Simple.FromRow PostField where
  fromRow = PostField
    <$> Simple.field
    <*> Simple.field
    <*> Simple.field
    <*> Simple.field

instance ToJSON PostField where
  toJSON (PostField a b c d) = object
    [ "id" .= a
    , "created_at" .= b
    , "updated_at" .= c
    , "slug" .= d
    ]

initialize :: (MonadReader Config m, MonadIO m) => m ()
initialize = do
  config <- ask
  let conn = _configConnection config
  liftIO $ Simple.execute_ conn "     \
    \ CREATE TABLE IF NOT EXISTS Post \
    \ ( id INTEGER PRIMARY KEY        \
    \ , created_at TEXT               \
    \ , updated_at TEXT               \
    \ , slug TEXT                     \
    \ );                              "

getPostList :: (MonadReader Config m, MonadIO m) => m [PostField]
getPostList = do
  config <- ask
  let conn = _configConnection config
  liftIO (Simple.query_ conn "SELECT * FROM Post" :: IO [PostField])

-- =============================================================================
-- Server
-- =============================================================================

policy :: Static.Policy
policy = Static.policy rewrite >-> Static.addBase "dist"
  where
    rewrite :: String -> Maybe String
    rewrite "" = Just "index.html"
    rewrite p = Just p

configure :: ConfigM a -> IO a
configure m = do
  connection <- Simple.open databaseName
  let config = Config { _configConnection = connection }
  runReaderT (runConfigM m) config

main :: IO ()
main = scottyOptsT def configure $ do
  let options = Static.defaultOptions
  Scotty.middleware $ Static.staticPolicyWithOptions options policy
  return ()
