{-# LANGUAGE DataKinds #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module Portfolio.Site.Post
( PostAPI (..)
, postServer
) where

--------------------------------------------------------------------------------
import Portfolio.Database.Post
import Portfolio.Env
import Portfolio.Model.Post
import Postlude
import Servant ((:>))

import qualified Servant
--------------------------------------------------------------------------------

type PostAPI = "posts" :> Servant.Get '[Servant.JSON] [Post]

postServer :: ReaderT Env IO (Servant.Server PostAPI)
postServer = do
  env <- ask
  let conn = _envConnection env
  posts <- lift $ getPosts conn
  return $ return posts