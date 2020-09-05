module Component.PostList
( component
) where

import Data.Maybe (Maybe(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Prelude

type State = Int

data Action = Increment | Decrement

component :: forall query input output m.
             H.Component HH.HTML query input output m
component = H.mkComponent
  { initialState
  , render
  , eval: H.mkEval $ H.defaultEval { handleAction = handleAction }
  }

initialState :: forall i. i -> State
initialState _ = 0

render :: forall m. State -> H.ComponentHTML Action () m
render state = HH.div_
  [ HH.button [ HE.onClick \_ -> Just Decrement ] [ HH.text "-" ]
  , HH.div_ [ HH.text $ show state ]
  , HH.button [ HE.onClick \_ -> Just Increment ] [ HH.text "+" ]
  ]

handleAction :: forall output m.
                Action -> H.HalogenM State Action () output m Unit
handleAction = case _ of
  Increment -> H.modify_ \state -> state + 1
  Decrement -> H.modify_ \state -> state - 1
