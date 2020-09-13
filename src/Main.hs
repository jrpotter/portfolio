{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module Main
( main
) where

import Control.Monad.Reader (ReaderT)
import Data.Function (($))
import Data.Int (Int)
import Data.Maybe (Maybe(Just))
import Data.Monoid (mconcat)
import Data.String (String)
import Network.Wai.Middleware.Static ((>->))
import System.IO (FilePath, IO)

import qualified Database.SQLite.Simple as Simple
import qualified Network.Wai.Middleware.Static as Static
import qualified Web.Scotty as Scotty

data Config = Config { connection :: Simple.Connection }

policy :: Static.Policy
policy = Static.policy rewrite >-> Static.addBase "dist"
  where
    rewrite :: String -> Maybe String
    rewrite "" = Just "index.html"
    rewrite p = Just p

main :: IO ()
main = do
  connection <- Simple.open "db/portfolio.db"
  let config = Config { connection = connection }
  Scotty.scotty 3000 $ do
    let options = Static.defaultOptions
    Scotty.middleware $ Static.staticPolicyWithOptions options policy
