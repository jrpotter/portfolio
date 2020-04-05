{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE TypeFamilies #-}

{-|

Primary entrypoint for our GHCJS frontend.

-}

module Main where

--------------------------------------------------------------------------------
import Portfolio.Env
import Portfolio.SVG
import Postlude

import qualified Control.Monad.Fix as Fix
import qualified Data.Map as Map
import qualified Data.Maybe as Maybe
import qualified Data.Text as Text
import qualified Reflex.Dom as Dom
import qualified System.FilePath as FilePath
import qualified System.IO as IO
--------------------------------------------------------------------------------

body :: Dom.MonadWidget t m => ReaderT Env m ()
body = Dom.el "div" $ do
  Dom.el "h1" $ Dom.text "Portfolio"
  -- Retrieve our posts from the backend. `getPostBuild` is an event triggered
  -- after the HTML page has been created.
  request <- postRequest
  postBuild <- Dom.getPostBuild
  raw <- Dom.performRequestAsync $ Dom.tag (Dom.constant request) postBuild
  -- Can display the output of our results
  let evResult = (Maybe.fromMaybe "" . Dom._xhrResponse_responseText) <$> raw
  Dom.dynText =<< Dom.holdDyn "" evResult

postRequest :: (Dom.MonadWidget t m) => ReaderT Env m (Dom.XhrRequest ())
postRequest = do
  env <- ask
  let url = _envServerURL env
  let path = Text.pack $ FilePath.joinPath $ map Text.unpack [url, "posts"]
  return $ Dom.XhrRequest "GET" path Dom.def

main :: IO ()
main = do
  let env = Env { _envServerURL = "http://127.0.0.1:8080" }
  Dom.mainWidget $ runReaderT body env
