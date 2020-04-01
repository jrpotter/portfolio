{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

{-

Servant API meant to serve our HTML landing page.

This page includes common GHCJS runtime javascript libraries needed to run our
code. It also contains the bare template to be initially served to the client so
at least something is visible while the (large) javascript files are passed over
and processed.

-}

module Portfolio.Prerender
( PrerenderAPI (..)
, prerenderServer
) where

--------------------------------------------------------------------------------
import Lucid
import Lucid.Html5
import Postlude

import qualified Data.Text as Text
import qualified Servant
import qualified Servant.HTML.Lucid as Lucid
--------------------------------------------------------------------------------

type PrerenderAPI = Servant.Get '[Lucid.HTML] (Html ())

prerenderServer :: Servant.Server PrerenderAPI
prerenderServer = return $ doctypehtml_ $ do
  head_ $ do
    title_ "FuzzyKayak"
    script_ [src_ "dist/rts.js"] ("" :: Text.Text)
    script_ [src_ "dist/lib.js"] ("" :: Text.Text)
    script_ [src_ "dist/out.js"] ("" :: Text.Text)
  body_ ""
