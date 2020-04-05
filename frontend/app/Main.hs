{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE TypeFamilies #-}

{-|

Primary entrypoint for our GHCJS frontend.

-}

module Main where

--------------------------------------------------------------------------------
import Portfolio.Env
import Portfolio.Model.Post
import Portfolio.SVG
import Postlude

import qualified Control.Monad.Fix as Fix
import qualified Data.Aeson as Aeson
import qualified Data.ByteString as ByteString
import qualified Data.Map as Map
import qualified Data.Maybe as Maybe
import qualified Data.Text as Text
import qualified Data.Text.Encoding as Encoding
import qualified Reflex.Dom as Dom
import qualified System.FilePath as FilePath
import qualified System.IO as IO
--------------------------------------------------------------------------------

-- | Construct the XHR request that will retrieve our posts.
--
-- This should hit our backend to retrieve information needed to construct DOM
-- elements listing our posts. Should only ever fire the once on post build.
postXhrRequest :: (Dom.MonadWidget t m) => ReaderT Env m (Dom.XhrRequest ())
postXhrRequest = do
  env <- ask
  let url = _envServerURL env
  let path = Text.pack $ FilePath.joinPath $ map Text.unpack [url, "posts"]
  return $ Dom.XhrRequest "GET" path Dom.def

-- | Wrapper around out posts.
--
-- Builds a `Dynamic` from our XHR response containing the decoded `Post`
-- responses. This only loads the once, but we wrap in a `Dynamic` anyways in
-- anticipation of eventual pagination.
postList :: ( Dom.DomBuilder t m
            , Dom.PostBuild t m
            , Dom.MonadHold t m
            , MonadFix m
            )
         => Dom.Event t Dom.XhrResponse
         -> m ()
postList e = do
  let response = (Maybe.fromMaybe "" . Dom._xhrResponse_responseText) <$> e
  let parsed = Dom.fmapMaybe (decode. Encoding.encodeUtf8) response
  result <- Dom.holdDyn [] parsed
  Dom.simpleList result postEntry
  return ()
  where
    decode :: ByteString.ByteString -> Maybe [Post]
    decode = Aeson.decodeStrict

-- | Widget used to display a single post entry.
--
-- Consists of a linked title, metadata about the post itself, and a snippet on
-- what the post is about.
postEntry :: (Dom.DomBuilder t m, Dom.PostBuild t m)
          => Dom.Dynamic t Post
          -> m ()
postEntry post = Dom.el "div" $ do
  Dom.el "h2" $ Dom.dynText $ _postTitle <$> post

-- | HTML element to place into our body tag.
body :: (Dom.MonadWidget t m) => ReaderT Env m ()
body = Dom.el "div" $ do
  Dom.el "h1" $ Dom.text "Portfolio"
  postBuild <- Dom.getPostBuild
  request <- postXhrRequest
  response <- Dom.performRequestAsync $ Dom.tag (Dom.constant request) postBuild
  postList response

main :: IO ()
main = do
  let env = Env { _envServerURL = "http://127.0.0.1:8080" }
  Dom.mainWidget $ runReaderT body env
