{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}
module Main where

import Postlude
import Reflex.Dom ((=:))

import qualified Control.Monad.Fix as Fix
import qualified Data.Map as Map
import qualified Data.Text as Text
import qualified Reflex.Dom as Dom
import qualified System.IO as IO

main :: IO ()
main = Dom.mainWidget sample
-- main = Dom.mainWidget $ do
--   rec
--     dynBool <- Dom.toggle False evClick
--     let dynAttrs = attrs <$> dynBool
--     Dom.elDynAttr "h1" dynAttrs $ Dom.text "changing color"
--     evClick <- Dom.button "Change Color"
--   return ()

sample :: (MonadFix m, Dom.MonadHold t m, Dom.DomBuilder t m, Dom.PostBuild t m) => m ()
sample = do
  rec
    dynBool <- Dom.toggle False evClick
    let dynAttrs = attrs <$> dynBool
    Dom.elDynAttrNS
      (Just "http://www.w3.org/2000/svg")
      "svg"
      (Dom.constDyn $ "width" =: "100" <> "height" =: "100") $ do
          Dom.elDynAttrNS (Just "http://www.w3.org/2000/svg") "circle" dynAttrs Dom.blank
    evClick <- Dom.button "Change color"
  return ()

attrs :: Bool -> Map.Map Text.Text Text.Text
attrs b = ("cx" =: "50" <> "cy" =: "50" <> "r" =: color b <> "stroke" =: "black" <> "stroke-width" =: "3" <> "fill" =: "red")
  where
    color True = "50"
    color _ = "40"
