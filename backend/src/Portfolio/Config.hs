module Portfolio.Config
( Config (..)
) where

--------------------------------------------------------------------------------
import Postlude

import qualified Database.PostgreSQL.Simple as Simple
--------------------------------------------------------------------------------

data Config = Config
  { -- | Connection to our PostgreSQL database.
    _configConnection :: Simple.Connection
  }
