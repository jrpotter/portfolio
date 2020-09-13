{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module Main
( main
) where

import Control.Applicative ((<*>))
import Control.Monad (return)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Control.Monad.Reader (MonadReader, ask, runReaderT)
import Data.Int (Int)
import Data.Function (($))
import Data.Functor ((<$>))
import Data.Maybe (Maybe(Just))
import Data.String (String)
import Data.Text (Text)
import Data.Time.Clock (UTCTime)
import Network.Wai.Middleware.Static ((>->))
import System.IO (IO)

import qualified Database.SQLite.Simple as Simple
import qualified Network.Wai.Middleware.Static as Static
import qualified Web.Scotty as Scotty

data Config = Config { _configConnection :: Simple.Connection }

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

getPosts :: (MonadReader Config m, MonadIO m) => m ()
getPosts = do
  config <- ask
  let conn = _configConnection config
  posts <- liftIO (Simple.query_ conn "SELECT * FROM Post" :: IO [PostField])
  return ()

-- =============================================================================
-- Server
-- =============================================================================

policy :: Static.Policy
policy = Static.policy rewrite >-> Static.addBase "dist"
  where
    rewrite :: String -> Maybe String
    rewrite "" = Just "index.html"
    rewrite p = Just p

main :: IO ()
main = do
  connection <- Simple.open databaseName
  let config = Config { _configConnection = connection }
  runReaderT initialize config
  Scotty.scotty 3000 $ do
    let options = Static.defaultOptions
    Scotty.middleware $ Static.staticPolicyWithOptions options policy
