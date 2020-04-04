{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module Portfolio.Site.Post
( PostAPI (..)
, postServer
) where

--------------------------------------------------------------------------------
import Postlude
import Portfolio.Config
import Portfolio.Model.Post
import Servant ((:>))

import qualified Data.Time.Calendar as Calendar
import qualified Data.Time.Clock as Clock
import qualified Servant
--------------------------------------------------------------------------------

type PostAPI = "posts" :> Servant.Get '[Servant.JSON] [Post]

postServer :: ReaderT Config IO (Servant.Server PostAPI)
postServer = do
  conf <- ask
  let conn = _configConnection conf
  posts <- lift $ getPosts conn
  return $ return posts
