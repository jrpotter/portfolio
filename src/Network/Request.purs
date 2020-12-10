module Network.Request
( decodeJson'
, request'
) where

import Affjax as X
import Data.Argonaut as A
import Data.Bifunctor (lmap)
import Data.Either (Either)
import Effect.Aff (Aff)
import Prelude

-- =============================================================================
-- Utility
-- =============================================================================

-- | Modifying of the `decodeJson` method provided by Argonaut.
--
-- For simplicity we convert the error type to a string so we can rope all of
-- our exception-like monads together.
decodeJson' :: forall a. A.DecodeJson a => A.Json -> Either String a
decodeJson' json =
  let result = A.decodeJson json in lmap A.printJsonDecodeError result

-- | Modifying of the `request` method provided by Affjax.
--
-- For simplicity we convert the error type to a string so we can rope all of
-- our exception-like monads together.
request' :: forall a. X.Request a -> Aff (Either String (X.Response a))
request' req = do
  result <- X.request req
  pure $ lmap X.printError result
