{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module Main where

--------------------------------------------------------------------------------
import Portfolio.Config
import Portfolio.Site.Post
import Portfolio.Site.Prerender
import Portfolio.Site.Static
import Postlude
import Servant ((:<|>))

import qualified Database.PostgreSQL.Simple as Simple
import qualified Network.Wai.Handler.Warp as Warp
import qualified Servant
import qualified System.IO as IO
--------------------------------------------------------------------------------

type API = PrerenderAPI :<|> PostAPI :<|> StaticAPI

api :: Servant.Proxy API
api = Servant.Proxy

server :: ReaderT Config IO (Servant.Server API)
server = do
  prerender <- prerenderServer
  post <- postServer
  static <- staticServer
  return $ prerender Servant.:<|> post Servant.:<|> static

init :: IO Config
init = do
  connection <- Simple.connectPostgreSQL ""
  Simple.execute_ connection "           \
  \ CREATE TABLE IF NOT EXISTS Post      \
  \ ( title VARCHAR(255) NOT NULL        \
  \ , slug VARCHAR(255) UNIQUE NOT NULL  \
  \ , published_at TIMESTAMPTZ NOT NULL    \
  \ , updated_at TIMESTAMPTZ NOT NULL      \
  \ , snippet TEXT NOT NULL              \
  \ );"
  return Config { _configConnection = connection
                , _configStaticDir = "/app/static/"
                }

main :: IO ()
main = do
  config <- init
  server <- runReaderT server config
  Warp.run 8080 $ Servant.serve api server
