{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}

{-|

Convenience methods for generating SVG from Reflex.

By default, Reflex does not provide any functionality. In addition, these
elements must be defined relative to the SVG namespace.

This code was slightly adapted from:
https://github.com/reflex-frp/reflex-dom-contrib/blob/master/src/Reflex/Dom/Contrib/Widgets/Svg.hs

-}

module Portfolio.SVG
( svg
, svg'
, svgAttr
, svgAttr'
, svgClass
, svgDynAttr
, svgDynAttr'
) where

--------------------------------------------------------------------------------
import Postlude
import Reflex.Dom ((=:))

import qualified Data.Map as Map
import qualified Data.Text as Text
import qualified Data.Tuple as Tuple
import qualified Reflex.Dom as Dom
--------------------------------------------------------------------------------

{-# INLINABLE svgDynAttr' #-}
svgDynAttr' :: (Dom.DomBuilder t m, Dom.PostBuild t m)
            => Text.Text
            -> Dom.Dynamic t (Map.Map Text.Text Text.Text)
            -> m a
            -> m (Dom.Element Dom.EventResult (Dom.DomBuilderSpace m) t, a)
svgDynAttr' = Dom.elDynAttrNS' (Just "http://www.w3.org/2000/svg")

{-# INLINABLE svgDynAttr #-}
svgDynAttr :: (Dom.DomBuilder t m, Dom.PostBuild t m)
           => Text.Text
           -> Dom.Dynamic t (Map.Map Text.Text Text.Text)
           -> m a
           -> m a
svgDynAttr elementTag attrs child =
  Tuple.snd <$> svgDynAttr' elementTag attrs child

{-# INLINABLE svgAttr' #-}
svgAttr' :: (Dom.DomBuilder t m, Dom.PostBuild t m)
         => Text.Text
         -> Map.Map Text.Text Text.Text
         -> m a
         -> m (Dom.Element Dom.EventResult (Dom.DomBuilderSpace m) t, a)
svgAttr' elementTag attrs child =
  svgDynAttr' elementTag (Dom.constDyn attrs) child

{-# INLINABLE svgAttr #-}
svgAttr :: (Dom.DomBuilder t m, Dom.PostBuild t m)
        => Text.Text
        -> Map.Map Text.Text Text.Text
        -> m a
        -> m a
svgAttr elementTag attrs child =
  svgDynAttr elementTag (Dom.constDyn attrs) child

{-# INLINABLE svg' #-}
svg' :: (Dom.DomBuilder t m, Dom.PostBuild t m)
     => Text.Text
     -> m a
     -> m (Dom.Element Dom.EventResult (Dom.DomBuilderSpace m) t, a)
svg' elementTag child = svgAttr' elementTag Map.empty child

{-# INLINABLE svg #-}
svg :: (Dom.DomBuilder t m, Dom.PostBuild t m) => Text.Text -> m a -> m a
svg elementTag child = svgAttr elementTag Map.empty child

{-# INLINABLE svgClass #-}
svgClass :: (Dom.DomBuilder t m, Dom.PostBuild t m)
         => Text.Text
         -> Text.Text
         -> m a
         -> m a
svgClass elementTag c child = svgAttr elementTag ("class" =: c) child