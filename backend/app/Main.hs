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

main :: IO ()
main = do
  connection <- Simple.connectPostgreSQL ""
  let config = Config { _configConnection = connection }
  server <- runReaderT server config
  Warp.run 8080 $ Servant.serve api server
