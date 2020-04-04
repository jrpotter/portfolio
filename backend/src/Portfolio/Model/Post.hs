{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TemplateHaskell #-}

{-
 
Represents the `Post` instance that exists within the database.

Contains methods used to query these posts.

TODO(jrpotter): Order fields by publish date. This doesn't really matter
currently since we currently have just one post.

TODO(jrpotter): Break this up so we can appropriately paginate. Again doesn't
matter currently since we have just the one post.

-}

module Portfolio.Model.Post
( Post (..)
, Post' (..)
, getPosts
, postTable
) where

--------------------------------------------------------------------------------
import Data.Aeson ((.=))
import Postlude

import qualified Data.Aeson as Aeson
import qualified Data.Profunctor.Product as Product
import qualified Data.Profunctor.Product.TH as TH
import qualified Data.Text as Text
import qualified Data.Time.Clock as Clock
import qualified Database.PostgreSQL.Simple as Simple
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

-- | A plain query used to pull out all of our posts.
postQuery :: Opaleye.Select PostField
postQuery = Opaleye.selectTable postTable

-- | Shortcut for retrieving all of the posts from the database.
getPosts :: Simple.Connection -> IO [Post]
getPosts conn = Opaleye.runSelect conn postQuery

-- | Set `ToJSON` instance for deserialization purposes.
instance Aeson.ToJSON Post where
  toJSON Post {..} = Aeson.object
    [ "title" .= _postTitle
    , "slug" .= _postSlug
    , "published_at" .= _postPublishedAt
    , "updated_at" .= _postUpdatedAt
    , "snippet" .= _postSnippet
    ]
