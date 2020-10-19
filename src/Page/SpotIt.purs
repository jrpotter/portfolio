module Page.SpotIt
( main
) where

import Affjax as AX
import Affjax.ResponseFormat as ResponseFormat
import Component.CodeBlock as CB
import Component.NavBar as NB
import Component.PostHeader as PH
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)
import Data.Argonaut as DA
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (log)
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)
import HighlightJS.Setup as HighlightJS
import MathJax.Setup as MathJax
import Model.Post as P
import Network.Request (decodeJson', request')
import Prelude
import Util.Selector (awaitApp)

main :: Effect Unit
main = HA.runHalogenAff do
  app <- awaitApp
  runUI component unit app

-- =============================================================================
-- Types
-- =============================================================================

type State = Maybe P.Post

data Action = Initialize | Load

type Slots =
  ( codeBlock :: forall query. H.Slot query Void Int
  , navBar :: forall query. H.Slot query Void Unit
  , postHeader :: forall query. H.Slot query Void Unit
  )

codeBlockProxy = SProxy :: SProxy "codeBlock"

navBarProxy = SProxy :: SProxy "navBar"

postHeaderProxy = SProxy :: SProxy "postHeader"

-- =============================================================================
-- Component
-- =============================================================================

component :: forall query input output m. MonadAff m
          => H.Component HH.HTML query input output m
component = H.mkComponent
  { initialState: \_ -> Nothing
  , render
  , eval: H.mkEval $ H.defaultEval
    { handleAction = handleAction
    , initialize = Just Initialize
    }
  }

handleAction :: forall output m. MonadAff m
             => Action -> H.HalogenM State Action Slots output m Unit

handleAction Initialize = do
  handleAction Load
  H.liftEffect HighlightJS.setup
  H.liftEffect MathJax.setup

handleAction Load = do
  result <- runExceptT do
     response <- ExceptT $ H.liftAff $ request' postRequest
     decoded <- ExceptT $ pure $ decodeJson' response.body
     P.readRaw decoded
  case result of
      Left err -> log $ "Could not get post: " <> err
      Right post -> H.put $ Just post

-- =============================================================================
-- Render
-- =============================================================================

introCard :: forall w i. Int -> HH.HTML w i
introCard num =
  let path = show num
      prefix = "https://portfolio-static.s3.amazonaws.com/spot-it/cards/"
   in
      HH.div
      [ HP.class_ (ClassName "intro-card") ]
      [ HH.img [ HP.src $ prefix <> path <> ".png" ]
      , HH.p_ [ HH.text $ "(" <> path <> ")" ]
      ]

render :: forall m. MonadAff m => State -> H.ComponentHTML Action Slots m
render Nothing = HH.div_ []
render (Just post) = HH.div_
  [ HH.slot navBarProxy unit NB.component absurd absurd
  , HH.div
    [ HP.class_ (ClassName "post-body") ]
    [ HH.slot postHeaderProxy unit PH.component post absurd
    -- -------------------------------------------------------------------------
    -- Introduction
    -- -------------------------------------------------------------------------
    , HH.h2_ [ HH.text "Introduction" ]
    , HH.p_ 
      [ HH.text """
        In light of Covid-19, my girlfriend and I have had to find different
        ways to keep ourselves preoccupied. When we aren't playing Animal
        Crossing or watching Community (or just need a break from screens in
        general), we've been playing a card game called "Spot it!". "Spot it!"
        is a party game consisting of 55 cards, each with a variety of different
        symbols, consisting of just a single matching symbol between any pair.
        For example, there exists just one common symbol on each pair of cards
        below:
        """
      ]
    , HH.div [ HP.id_ "intro-cards" ] (map introCard [1, 2, 3])
    , HH.p_
      [ HH.text """
        Between cards (1) and (2) we see the orangish treble clef; between cards
        (2) and (3) we see the word "ART"; between cards (1) and (3) we see the
        water drop. Furthermore, on careful inspection, we'll see that these are
        the only matches for these pairs. These cards are 3 of the 55 cards
        included in the "Spot it!" game but this property is true between any of
        the \(\binom{55}{2}\) possible pairs. This post will briefly touch on
        the math explaining how this property holds and will then look at how we
        can automate finding these matches.
        """
      ]
    -- -------------------------------------------------------------------------
    -- Mathematics
    -- -------------------------------------------------------------------------
    , HH.h2_ [ HH.text "Mathematics" ]
    , HH.p_
      [ HH.text """
        To start, let's look into formalizing what it is we want to show. Let
        \(S = \{s_1, s_2, \ldots, s_n\}\) be a finite set of \(n\) symbols and
        \(C = \{c_1, c_2, \ldots, c_N\}\) be a finite set of \(N\) cards, each
        containing some subset of \(S\) of size \(k\) such that \(1 \leq k \leq
        n\). Let \(\mathit{sym}: C \rightarrow P(S)\) be a function such that
        for all \(1 \leq i \leq N\),

        \[ \mathit{sym}(c_i) = \{s_{i_1}, s_{i_2}, \ldots, s_{i_k}\}, \]

        where \(P\) denotes the powerset operation. That is, \(\mathit{sym}\)
        denotes the \(k\) symbols on card \(c_i\). We want to know if there
        exists some configuration of \(C\) such that for all pairs of cards
        \(c_i, c_j \in C\) where \(i \neq j\),

        \[ |\mathit{sym}(c_i) \cap \mathit{sym}(c_j)| = 1. \]
        """
      ]
    , HH.p_
      [ HH.text "As a starting point, let's consider some trivial examples." ]
    , HH.table
      [ HP.id_ "table-conf" ]
      [ HH.tr_
        [ HH.th_ [ HH.text """\(S\)""" ]
        , HH.th_ [ HH.text """\(C\)""" ]
        ]
      , HH.tr_
        [ HH.td
          [ HP.colSpan 2 ]
          [ HH.text "No Configuration" ]
        ]
      , HH.tr_
        [ HH.td_ [ HH.text """\(\{\}\)""" ]
        , HH.td_ [ HH.text """\(\{\}\)""" ]
        ]
      , HH.tr_
        [ HH.td_ [ HH.text """\(\{s_1\}\)""" ]
        , HH.td_ [ HH.text """\(\{\}\)""" ]
        ]
      , HH.tr_
        [ HH.td_ [ HH.text """\(\{\}\)""" ]
        , HH.td_ [ HH.text """\(\{c_1, c_2\}\)""" ]
        ]
      , HH.tr_
        [ HH.td
          [ HP.colSpan 2 ]
          [ HH.text "One Configuration" ]
        ]
      , HH.tr_
        [ HH.td_ [ HH.text """\(\{\}\)""" ]
        , HH.td_ [ HH.text """\(\{c_1\}\)""" ]
        ]
      , HH.tr_
        [ HH.td_ [ HH.text """\(\{s_1\}\)""" ]
        , HH.td_ [ HH.text """\(\{c_1, c_2\}\)""" ]
        ]
      ]
    , HH.p_
      [ HH.text """
        Here we are stating that for e.g. \(S = \{\}, C = \{\}\), there exists
        no configuration of cards satisfying our desired property. Similarly,
        for \(S = \{s_1\}, C = \{c_1, c_2\}\), there exists one configuration.
        Before diving further into this, let's look at a more complicated
        example:

        \[ S = \{a, b, c, d\}, k = 2 \]
        """
      ]
    , HH.img
      [ HP.id_ "group-example"
      , HP.src "/imgs/spot-it/group-example.svg"
      ]
    , HH.p
      [ HH.text """
        Here we see an interesting property manifest. What we have looks to be
        similar to a Cayley graph of Factor Groups? Remind myself of how this
        might fit but we have a series of permutations and we have potentially
        some "subgroup" construction.
        """
    , HH.slot codeBlockProxy 0 CB.component
       { code: """
         data Dog = Apple | Banana
         print "1 + 1"
         """
       , lang: "haskell"
       } absurd
    ]
  ]

-- =============================================================================
-- Introduction
-- =============================================================================

postRequest :: AX.Request DA.Json
postRequest = AX.defaultRequest
  { url = "/api/post/spot-it"
  , method = Left GET
  , responseFormat = ResponseFormat.json
  }
