{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE CPP #-}

module Main where

--------------------------------------------------------------------------------
import Miso ((<#))
import Postlude

import qualified Control.Monad.IO.Class
import qualified Miso
import qualified Miso.String as String
import qualified System.IO as IO

#ifndef __GHCJS__
import qualified Language.Javascript.JSaddle.Warp as JSaddle
import qualified Network.Wai.Handler.Warp as Warp
import qualified Network.WebSockets as WebSockets
#endif
--------------------------------------------------------------------------------

#ifndef __GHCJS__
runApp :: Miso.JSM () -> IO ()
runApp f = do
  let settings = Warp.setTimeout 3600 Warp.defaultSettings
  let options = WebSockets.defaultConnectionOptions
  conn <- JSaddle.jsaddleOr options (f >> Miso.syncPoint) JSaddle.jsaddleApp
  Warp.runSettings settings conn
#else
runApp :: IO () -> IO ()
runApp app = app
#endif

-- | Entry point for a miso application
main :: IO ()
main = runApp $ Miso.startApp Miso.App {..}
  where
    initialAction = SayHelloWorld -- initial action to be executed on application load
    model  = 0                    -- initial model
    update = updateModel          -- update function
    view   = viewModel            -- view function
    events = Miso.defaultEvents        -- default delegated events
    subs   = []                   -- empty subscription list
    mountPoint = Nothing          -- mount point for application (Nothing defaults to 'body')

--------------------------------------------------------------------------------

-- | Type synonym for an application model
type Model = Int

-- | Sum type for application events
data Action
  = AddOne
  | SubtractOne
  | NoOp
  | SayHelloWorld
  deriving (Show, Eq)

-- | Updates model, optionally introduces side effects
updateModel :: Action -> Model -> Miso.Effect Action Model
updateModel AddOne m = Miso.noEff (m + 1)
updateModel SubtractOne m = Miso.noEff (m - 1)
updateModel NoOp m = Miso.noEff m
updateModel SayHelloWorld m = m <# do
  liftIO (IO.putStrLn "Hello World") >> pure NoOp

-- | Constructs a virtual DOM from a model
viewModel :: Model -> Miso.View Action
viewModel x = Miso.div_ [] [
   Miso.button_ [ Miso.onClick AddOne ] [ Miso.text "+" ]
 , Miso.text (String.ms x)
 , Miso.button_ [ Miso.onClick SubtractOne ] [ Miso.text "-" ]
 ]
