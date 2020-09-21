module Network.Request
( decodeJson'
, request'
) where

import Affjax as AX
import Model.Post as P
import Data.Argonaut as DA
import Data.Either (Either(..))
import Effect.Aff (Aff)
import Prelude

-- =============================================================================
-- Utility
-- =============================================================================

mapLeft :: forall a b c. (a -> b) -> Either a c -> Either b c
mapLeft f (Left e) = Left $ f e
mapLeft f (Right e) = Right e

-- | Modifying of the `decodeJson` method provided by Argonaut.
--
-- For simplicity we convert the error type to a string so we can rope all of
-- our exception-like monads together.
decodeJson' :: forall a. DA.DecodeJson a => DA.Json -> Either String a
decodeJson' json =
  let result = DA.decodeJson json in mapLeft DA.printJsonDecodeError result

-- | Modifying of the `request` method provided by Affjax.
--
-- For simplicity we convert the error type to a string so we can rope all of
-- our exception-like monads together.
request' :: forall a. AX.Request a -> Aff (Either String (AX.Response a))
request' req = do
  result <- AX.request req
  pure $ mapLeft AX.printError result
