module Portfolio.Env
( Env (..)
) where

--------------------------------------------------------------------------------
import Postlude

import qualified Data.Text as Text
--------------------------------------------------------------------------------

data Env = Env
  { -- | The url of the host we want XHR requests to be relative to.
    _envServerURL :: Text.Text
  }
