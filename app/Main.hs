module Main
( main
) where

import Data.Function (($))
import Data.Monoid (mconcat)
import System.IO (IO)

import qualified Web.Scotty as WS

main :: IO ()
main = WS.scotty 3000 $
  WS.get "/:word" $ do
    beam <- WS.param "word"
    WS.html $ mconcat ["<h1>Scotty, ", beam, "me up!"]
