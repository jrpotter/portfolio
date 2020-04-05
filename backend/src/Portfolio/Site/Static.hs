{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

{-|

Servant API meant to serve static files.

-}

module Portfolio.Site.Static
( StaticAPI (..)
, staticServer
) where

--------------------------------------------------------------------------------
import Portfolio.Config
import Postlude
import Servant ((:>))

import qualified Data.Text as Text
import qualified Servant
--------------------------------------------------------------------------------

type StaticAPI = "static" :> Servant.Raw

staticServer :: ReaderT Config IO (Servant.Server StaticAPI)
staticServer = do
  conf <- ask
  let dir = Text.unpack $ _configStaticDir conf
  return $ Servant.serveDirectoryWebApp dir
