module Page.Index
( main
) where

import Component.NavBar as NB
import Component.PostList as PostList
import Data.Symbol (SProxy(..))
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.VDom.Driver (runUI)
import Prelude
import Util.Selector (awaitApp)

main :: Effect Unit
main = HA.runHalogenAff do
  app <- awaitApp
  runUI component unit app

-- =============================================================================
-- Slots
-- =============================================================================

type Slots =
  ( navBar :: forall query. H.Slot query Void Unit
  , postList :: forall query. H.Slot query Void Unit
  )

navBarProxy = SProxy :: SProxy "navBar"

postListProxy = SProxy :: SProxy "postList"

-- =============================================================================
-- Component
-- =============================================================================

type State = Unit

component :: forall query input output m. MonadAff m
          => H.Component HH.HTML query input output m
component = H.mkComponent
  { initialState: \_ -> unit
  , render
  , eval: H.mkEval H.defaultEval
  }

render :: forall m. MonadAff m => State -> H.ComponentHTML Unit Slots m
render state = HH.div_
  [ HH.slot navBarProxy unit NB.component absurd absurd
  , HH.slot postListProxy unit PostList.component absurd absurd
  ]
