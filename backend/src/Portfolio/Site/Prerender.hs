{-# LANGUAGE DataKinds #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

{-|

Servant API meant to serve our HTML landing page.

This page includes common GHCJS runtime javascript libraries needed to run our
code. It also contains the bare template to be initially served to the client so
at least something is visible while the (large) javascript files are passed over
and processed.

-}

module Portfolio.Site.Prerender
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

prerenderServer :: ReaderT r IO (Servant.Server PrerenderAPI)
prerenderServer = return $ return $ doctypehtml_ $ do
  head_ $ do
    title_ "FuzzyKayak"
    -- MathJax-related scripts.
    script_
      [src_ "https://polyfill.io/v3/polyfill.min.js?features=es6"]
      ("" :: Text.Text)
    script_
      [ id_ "MathJax-script"
      , src_ "https://cdn.jsdelivr.net/npm/mathjax@3.0.1/es5/tex-mml-chtml.js"
      , async_ ""
      ]
      ("" :: Text.Text)
    -- Custom highlight pack that only includes languages we expect to use.
    script_ [src_ "static/highlight.pack.js"] ("" :: Text.Text)
    -- GHCJS scripts to be injected at docker build.
    script_ [src_ "static/rts.js"] ("" :: Text.Text)
    script_ [src_ "static/lib.js"] ("" :: Text.Text)
    script_ [src_ "static/out.js"] ("" :: Text.Text)
  body_ $ script_ "h$main(h$mainZCMainzimain);"