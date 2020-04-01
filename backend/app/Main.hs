{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module Main where

--------------------------------------------------------------------------------
import Postlude
import Portfolio.Prerender
import Portfolio.Static
import Servant ((:<|>))

import qualified Network.Wai.Handler.Warp as Warp
import qualified Servant
import qualified System.IO as IO
--------------------------------------------------------------------------------

type API = PrerenderAPI :<|> StaticAPI

api :: Servant.Proxy API
api = Servant.Proxy

server :: Servant.Server API
server = prerenderServer Servant.:<|> staticServer

main :: IO ()
main = Warp.run 8080 $ Servant.serve api server
