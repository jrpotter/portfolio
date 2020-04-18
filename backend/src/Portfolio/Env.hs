{-# LANGUAGE NoImplicitPrelude #-}

module Portfolio.Env
( Env (..)
) where

--------------------------------------------------------------------------------
import Postlude

import qualified Data.Text as Text
import qualified Database.PostgreSQL.Simple as Simple
--------------------------------------------------------------------------------

data Env = Env
  { -- | Connection to our PostgreSQL database.
    _envConnection :: Simple.Connection
  , -- | The location of our static files.
    _envStaticDir :: Text.Text
  }