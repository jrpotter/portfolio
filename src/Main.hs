{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module Main
( main
) where

import Data.Function (($))
import Data.Maybe (Maybe(Just))
import Data.Monoid (mconcat)
import Data.String (String)
import Network.Wai.Middleware.Static ((>->))
import System.IO (FilePath, IO)

import qualified Network.Wai.Middleware.Static as M
import qualified Web.Scotty as WS

policy :: M.Policy
policy = M.policy rewrite >-> M.addBase "dist"
  where
    rewrite :: String -> Maybe String
    rewrite "" = Just "index.html"
    rewrite p = Just p

main :: IO ()
main = WS.scotty 3000 $ do
  WS.middleware $ M.staticPolicyWithOptions M.defaultOptions policy
