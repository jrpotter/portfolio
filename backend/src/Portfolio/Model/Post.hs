{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}

module Portfolio.Model.Post
( postTable
) where

--------------------------------------------------------------------------------
import Postlude

import qualified Data.Profunctor.Product.TH as TH
import qualified Data.Profunctor.Product as Product
import qualified Data.Text as Text
import qualified Data.Time.Clock as Clock
import qualified Opaleye
--------------------------------------------------------------------------------

data Post' a b c d e = Post
  { -- | Field representing the title of our post.
    _postTitle :: a
  , -- | Field representing the slug of our post.
    --
    -- This field is used as a unique identifier of our posts. A symbolic link
    -- contained within our static directory should exist with name matching
    -- this identifier. This link should point to a GHCJS generated file
    -- containing the actual contents of our post.
    _postSlug :: b
  , -- | Field indicating when our post was initially published to the site.
    _postPublishedAt :: c
  , -- | Field indicating When our post was last updated.
    --
    -- This should always exceed the `published_at` time.
    _postUpdatedAt :: d
  , -- | A snippet to display as a preview of the post.
    --
    -- Can be viewed as the abstract of the post, giving a quick description of
    -- what the post is about. This field should be interpreted as unescaped
    -- HTML.
    _postSnippet :: e
  }

-- | A concrete implementation of the above record type compatible with Opaleye.
type Post = Post' Text.Text Text.Text Clock.UTCTime Clock.UTCTime Text.Text

-- | The columns we allow reading and writing to.
--
-- Generally speaking, we probably don't want to write to this table using our
-- backend code; we'll generally be linking everything up by hand or via some
-- simple script that:
--
-- 1) Generates the GHCJS file corresponding to the post.
-- 2) Creates a symbolic link in the `backend` pointing to this file.
-- 3) Adds an entry to our database table.
type PostField = Post' (Opaleye.Field Opaleye.SqlText)
                       (Opaleye.Field Opaleye.SqlText)
                       (Opaleye.Field Opaleye.SqlTimestamptz)
                       (Opaleye.Field Opaleye.SqlTimestamptz)
                       (Opaleye.Field Opaleye.SqlText)
                       

$(TH.makeAdaptorAndInstance "pPost" ''Post')

-- | Reference to the post table we'll query for path information.
postTable :: Opaleye.Table PostField PostField
postTable = Opaleye.table "post" $ pPost Post
  { _postTitle = Opaleye.tableField "title"
  , _postSlug = Opaleye.tableField "slug"
  , _postPublishedAt = Opaleye.tableField "published_at"
  , _postUpdatedAt = Opaleye.tableField "updated_at"
  , _postSnippet = Opaleye.tableField "snippet"
  }
