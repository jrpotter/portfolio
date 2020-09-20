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
import Data.Default.Class (def)
import Data.Either (Either(..))
import Data.Function (($))
import Data.Functor ((<$>), Functor)
import Data.Int (Int)
import Data.Maybe (Maybe(..), listToMaybe)
import Data.String (String)
import Data.Text.Lazy (Text, fromStrict)
import Data.Time.Clock (UTCTime)
import Network.HTTP.Types.Status (status404)
import Network.Wai.Middleware.Static ((>->))
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

getPost' :: (MonadReader Config m, MonadIO m) => String -> ActionT Text m ()
getPost' slug = do
  post <- getPost slug
  case post of
    Just r -> Scotty.json r
    Nothing -> Scotty.status status404

getPostList :: (MonadReader Config m, MonadIO m) => m [PostField]
getPostList = do
  config <- ask
  let conn = _configConnection config
  liftIO $ query conn
  where
    query :: Simple.Connection -> IO [PostField]
    query c = Simple.query_ c "SELECT * FROM Post ORDER BY created_at DESC"

getPostList' :: (MonadReader Config m, MonadIO m) => ActionT Text m ()
getPostList' = do
  posts <- getPostList
  Scotty.json posts

-- =============================================================================
-- Server
-- =============================================================================

newtype Script = Script { runScript :: String }

instance ToMustache Script where
  toMustache (Script value) = Mustache.object ["script" ~> value]

startServer :: Template -> IO ()
startServer template = do
  conn <- Simple.open databaseName
  let config = Config { _configConnection = conn }
  -- Initialize our database before running the Scotty app to avoid this
  -- being hit everytime we process an action.
  runReaderT initialize config
  -- Allow passing in the config throughout our various Scotty actions. Example
  -- pulled from:
  -- https://github.com/scotty-web/scotty/blob/master/examples/reader.hs
  scottyOptsT def (\m -> runReaderT (runConfigM m) config) $ do
    let options = Static.defaultOptions
    let policy = Static.addBase "dist"
    Scotty.middleware $ Static.staticPolicyWithOptions options policy
    -- Return our homepage and specifically our homepage result.
    Scotty.get "" $ do
      Scotty.html $ fromStrict $ substitute template (Script "index")
    -- Retrieve a single post or a list of all posts.
    Scotty.get "/api/post/:slug" $ do
      slug <- Scotty.param "slug"
      getPost' slug
    Scotty.get "/api/posts" getPostList'
    -- Pull in a specific HTML file containing our post.
    Scotty.get "/post/:slug" $ do
      slug <- Scotty.param "slug"
      Scotty.html $ fromStrict $ substitute template (Script slug)

main :: IO ()
main = do
  -- Compile our Mustache template and cache the result for use across requests.
  -- We only have the one template as of now that consists of a custom script
  -- we can load. This way, we can include javascript/CSS specific to a given
  -- `Post` instead of including all post-specific code across all pages
  -- unnecessarily.
  compiled <- automaticCompile [".", "./dist"] "index.html"
  case compiled of
    Left err -> putStrLn $ show err
    Right template -> startServer template
