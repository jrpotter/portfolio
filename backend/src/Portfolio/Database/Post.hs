{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

{-|
 
Represents the `Post` instance that exists within the database.

Contains methods used to query these posts.

TODO(jrpotter): Order fields by publish date. This doesn't really matter
currently since we currently have just one post.

TODO(jrpotter): Break this up so we can appropriately paginate. Again doesn't
matter currently since we have just the one post.

-}

module Portfolio.Database.Post
( getPosts
, postTable
) where

--------------------------------------------------------------------------------
import Portfolio.Model.Post
import Postlude

import qualified Data.Profunctor.Product as Product
import qualified Data.Profunctor.Product.TH as TH
import qualified Database.PostgreSQL.Simple as Simple
import qualified Opaleye
--------------------------------------------------------------------------------

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