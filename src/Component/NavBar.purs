module Component.NavBar
( component
) where

import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Properties as HP
import Prelude

type State = Unit

component :: forall query input output m.
             H.Component HH.HTML query input output m
component = H.mkComponent
  { initialState: \_ -> unit
  , render
  , eval: H.mkEval H.defaultEval
  }

render :: forall m. State -> H.ComponentHTML Unit () m
render state = HH.div
  [ HP.id_ "navbar" ]
  [ HH.h1_
    [ HH.text "FuzzyKayak" ]
  , HH.img
    [ HP.src "https://avatars2.githubusercontent.com/u/3267697?s=180&v=4" ]
  ]
