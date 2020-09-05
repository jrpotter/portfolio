module Model.Post
( Post(..)
) where

import Data.DateTime (DateTime)

type Post = { title :: String, datetime :: DateTime }
