{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}

{-|

Primary entrypoint for our GHCJS frontend.

-}

module Pages.Index where

--------------------------------------------------------------------------------
import Portfolio.Env
import Portfolio.Model.Post
import Portfolio.SVG
import Postlude
import Reflex.Dom ((=:))

import qualified Control.Monad.Fix as Fix
import qualified Data.Aeson as Aeson
import qualified Data.ByteString as ByteString
import qualified Data.Map as Map
import qualified Data.Maybe as Maybe
import qualified Data.Time as Time
import qualified Data.Time.Clock as Clock
import qualified Data.Text as Text
import qualified Data.Text.Encoding as Encoding
import qualified Reflex.Dom as Dom
import qualified System.FilePath as FilePath
import qualified System.IO as IO
--------------------------------------------------------------------------------

main :: IO ()
main = do
  let env = Env { _envServerURL = "http://127.0.0.1:8080" }
  Dom.mainWidget $ runReaderT bodyW env

bodyW :: (Dom.MonadWidget t m) => ReaderT Env m ()
bodyW = Dom.el "div" $ do
  Dom.el "h1" $ Dom.text "Portfolio"
  postBuild <- Dom.getPostBuild
  request <- postXhrRequest
  response <- Dom.performRequestAsync $ Dom.tag (Dom.constant request) postBuild
  postListW response

--------------------------------------------------------------------------------
-- XHR
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

--------------------------------------------------------------------------------
-- Post Widgets
--------------------------------------------------------------------------------

-- | Widget used to display a title link.
titleW :: (Dom.DomBuilder t m, Dom.PostBuild t m)
       => Dom.Dynamic t Text.Text
       -> Dom.Dynamic t Text.Text
       -> m ()
titleW title slug = do
  let attrs = (link "title") <$> slug
  Dom.elDynAttr "a" attrs $ Dom.el "h2" $ Dom.dynText title
  where
    link :: Text.Text -> Text.Text -> Map.Map Text.Text Text.Text
    link cls t = ("class" =: cls) <> ("href" =: t)

-- | Widget used to display a formatted time.
timeW :: (Dom.DomBuilder t m, Dom.PostBuild t m)
      => Dom.Dynamic t Clock.UTCTime
      -> m ()
timeW c = Dom.elClass "div" "time" $ Dom.dynText $ format <$> c
  where
    format :: Clock.UTCTime -> Text.Text
    format t = Text.pack $ Time.formatTime
      Time.defaultTimeLocale "%B %d, %Y at %I:%M:%S %p" t

-- | Widget used to display a single post entry.
--
-- Consists of a linked title, metadata about the post itself, and a snippet on
-- what the post is about.
postW :: (Dom.DomBuilder t m, Dom.PostBuild t m) => Dom.Dynamic t Post -> m ()
postW post = Dom.el "div" $ do
  titleW (_postTitle <$> post) (_postSlug <$> post)
  timeW $ _postPublishedAt <$> post
  timeW $ _postUpdatedAt <$> post

-- | Widget containing all of our posts.
--
-- Builds a `Dynamic` from our XHR response containing the decoded `Post`
-- responses. This only loads the once, but we wrap in a `Dynamic` anyways in
-- anticipation of eventual pagination.
postListW :: ( Dom.DomBuilder t m
             , Dom.PostBuild t m
             , Dom.MonadHold t m
             , MonadFix m
             )
          => Dom.Event t Dom.XhrResponse
          -> m ()
postListW e = do
  let response = (Maybe.fromMaybe "" . Dom._xhrResponse_responseText) <$> e
  let parsed = Dom.fmapMaybe (decode. Encoding.encodeUtf8) response
  result <- Dom.holdDyn [] parsed
  Dom.simpleList result postW
  return ()
  where
    decode :: ByteString.ByteString -> Maybe [Post]
    decode = Aeson.decodeStrict