{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}

{-|

Primary entrypoint for our GHCJS frontend.

-}

module Main where

--------------------------------------------------------------------------------
import Portfolio.SVG
import Postlude
import Reflex.Dom ((=:))

import qualified Control.Monad.Fix as Fix
import qualified Data.Map as Map
import qualified Data.Text as Text
import qualified Reflex.Dom as Dom
import qualified System.IO as IO
--------------------------------------------------------------------------------

main :: IO ()
main = Dom.mainWidget sample

sample :: ( MonadFix m
          , Dom.MonadHold t m
          , Dom.DomBuilder t m
          , Dom.PostBuild t m
          )
       => m ()
sample = do
  rec
    dynBool <- Dom.toggle False evClick
    let dynAttrs = attrs <$> dynBool
    svgDynAttr "svg" parent $ svgDynAttr "circle" dynAttrs Dom.blank
    evClick <- Dom.button "Change color"
  return ()
  where
    parent = Dom.constDyn $ "width" =: "100" <> "height" =: "100"

attrs :: Bool -> Map.Map Text.Text Text.Text
attrs b = (  "cx" =: "50"
          <> "cy" =: "50"
          <> "r" =: color b
          <> "stroke" =: "black"
          <> "stroke-width" =: "3"
          <> "fill" =: "red"
          )
  where
    color True = "50"
    color _ = "40"
