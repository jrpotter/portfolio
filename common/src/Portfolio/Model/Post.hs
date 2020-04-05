{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Portfolio.Model.Post
( Post (..)
, Post' (..)
) where

--------------------------------------------------------------------------------
import Data.Aeson ((.:), (.=))
import Postlude

import qualified Data.Aeson as Aeson
import qualified Data.Text as Text
import qualified Data.Time.Clock as Clock
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

--------------------------------------------------------------------------------
-- JSON Handling
--------------------------------------------------------------------------------

instance Aeson.ToJSON Post where
  toJSON Post {..} = Aeson.object
    [ "title" .= _postTitle
    , "slug" .= _postSlug
    , "published_at" .= _postPublishedAt
    , "updated_at" .= _postUpdatedAt
    , "snippet" .= _postSnippet
    ]

instance Aeson.FromJSON Post where
  parseJSON = Aeson.withObject "Post" $ \v -> Post
    <$> v .: "title"
    <*> v .: "slug"
    <*> v .: "published_at"
    <*> v .: "updated_at"
    <*> v .: "snippet"
