module Portfolio.Config
( Config (..)
) where

--------------------------------------------------------------------------------
import Postlude

import qualified Data.Text as Text
import qualified Database.PostgreSQL.Simple as Simple
--------------------------------------------------------------------------------

data Config = Config
  { -- | Connection to our PostgreSQL database.
    _configConnection :: Simple.Connection
  , -- | The location of our static files.
    _configStaticDir :: Text.Text
  }
