{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

{-

Servant API meant to serve static files.

-}

module Portfolio.Static
( StaticAPI (..)
, staticServer
) where

--------------------------------------------------------------------------------
import Postlude
import Servant ((:>))

import qualified Servant
--------------------------------------------------------------------------------

type StaticAPI = "static" :> Servant.Raw

staticServer :: Servant.Server StaticAPI
staticServer = Servant.serveDirectoryWebApp
  "/home/jrpotter/Documents/portfolio/backend/static/"
