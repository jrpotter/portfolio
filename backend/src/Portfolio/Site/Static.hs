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
import Portfolio.Env
import Postlude
import Servant ((:>))

import qualified Data.Text as Text
import qualified Servant
--------------------------------------------------------------------------------

type StaticAPI = "static" :> Servant.Raw

staticServer :: ReaderT Env IO (Servant.Server StaticAPI)
staticServer = do
  env <- ask
  let dir = Text.unpack $ _envStaticDir env
  return $ Servant.serveDirectoryWebApp dir
