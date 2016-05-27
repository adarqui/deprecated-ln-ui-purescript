module LN.View.Leurons.Mod (
  renderView_Leurons_New,
  renderView_Leurons_Edit,
  renderView_Leurons_Mod
) where



import Data.Maybe                      (Maybe(..), maybe)
import Data.Tuple                      (Tuple(..))
import Halogen                         (ComponentHTML)
import Halogen.HTML.Indexed            as H
import Halogen.HTML.Events             as E
import Halogen.HTML.Properties.Indexed as P
import Halogen.Themes.Bootstrap3       as B
import Prelude                         (id, map, show, const, ($), (<<<), (<>))

import LN.Halogen.Util
import LN.Helpers.Array                (seqArrayFrom)
import LN.Helpers.JSON                 (decodeString)
-- import LN.Internal.Leuron
import LN.Input.Leuron
import LN.Input.Types                  (Input(..), cLeuronMod)
import LN.State.Loading                (getLoading, l_currentLeuron)
import LN.State.Leuron                 (LeuronRequestState)
import LN.State.Types                  (State)
import LN.View.Module.Loading          (renderLoading)
import LN.T



renderView_Leurons_New :: State -> ComponentHTML Input
renderView_Leurons_New = renderView_Leurons_Mod Nothing



renderView_Leurons_Edit :: Int -> State -> ComponentHTML Input
renderView_Leurons_Edit leuron_id = renderView_Leurons_Mod (Just leuron_id)



renderView_Leurons_Mod :: Maybe Int -> State -> ComponentHTML Input
renderView_Leurons_Mod m_leuron_id st =
  case st.currentLeuronRequest, st.currentLeuronRequestSt, getLoading l_currentLeuron st.loading of
    _, _, true                         -> renderLoading
    Just leuron_req, Just rst, false -> renderView_Leurons_Mod' m_leuron_id leuron_req rst st
    _, _, false                        -> H.div_ [H.p_ [H.text "unexpected error."]]



renderView_Leurons_Mod' :: Maybe Int -> LeuronRequest -> LeuronRequestState -> State -> ComponentHTML Input
renderView_Leurons_Mod' m_leuron_id leuron_req lst st =
  H.div_ [

      H.h1_ [ H.text "Add Leuron" ]

--    , H.h2_ [ H.text $ "For resource: " <> resource.resourceTitle ]



  -- LeuronData

   , radioMenu
      "Leuron Type"
      "leuron-type"
      [ TyLnEmpty, TyLnFact, TyLnFactList, TyLnCard, TyLnDCard, TyLnDCardX, TyLnAcronym
      , TyLnSynonym, TyLnAntonym, TyLnTemplate, TyLnImageAssociation, TyLnLinearDemo
      , TyLnTable, TyLnScript, TyLnQA, TyLnExamples
      ]
      (cLeuronMod <<< SetType)
      lst.ty

   , case lst.ty of
          TyLnEmpty    -> empty
--          TyLnFact     -> fact lst.fact
{-
          TyLnFactList -> factList lst.factList
          TyLnCard     -> card lst.card
          TyLnDCard    -> dcard lst.dcard
-}



  -- Title

  , input_maybeField_DeleteEdit
      P.InputText
      "Title"
      leuron.title
      (E.input_ (cLeuronMod $ SetTitle ""))
      (E.input (\new -> cLeuronMod $ SetTitle new))
      (E.input_ (cLeuronMod $ RemoveTitle))



  -- Description

  , input_maybeField_DeleteEdit
      P.InputText
      "Description"
      leuron.description
      (E.input_ (cLeuronMod $ SetDescription ""))
      (E.input (\new -> cLeuronMod $ SetDescription new))
      (E.input_ (cLeuronMod $ RemoveDescription))



  -- Section

  , input_maybeField_DeleteEdit
      P.InputText
      "Section"
      leuron.section
      (E.input_ (cLeuronMod $ SetSection ""))
      (E.input (\new -> cLeuronMod $ SetSection new))
      (E.input_ (cLeuronMod $ RemoveSection))



  -- Examples
--  , textArea_LabelWithButton "Examples" "Example" "" "Add" (E.input ModifyLeuronExamples) (E.input_ AddLeuronExamples)

  , H.div_ $
      map (\example ->
        textArea_DeleteEdit
          example
          (E.input (\new -> cLeuronMod $ EditExample 0 new))
          (E.input_ (cLeuronMod $ DeleteExample 0)) -- TODO FIXME
      ) $ maybe [] id leuron.examples




  -- Strengths

{-
TODO: add this back, removing for now
  , input_Label "Strengths" "Strength" "" P.InputText  (E.input AddLeuronStrengths)

  , H.div_ $
      map (\strength ->
        input_DeleteEdit
          P.InputText
          strength
          (E.input (\new -> EditLeuronStrengths strength new))
          (E.input_ (RemoveLeuronStrengths strength))
      ) leuron.leuronStrengths
-}



  -- Categories

  , input_Label "Categories" "Category" "" P.InputText  (E.input_ (cLeuronMod $ AddCategory [])) -- <<< decode))

  , H.div_ $
      map (\category ->
        input_DeleteEdit
          P.InputText
          (show category)
          (E.input (\new -> cLeuronMod $ EditCategory 0 [])) -- TODO FIXME (decode new)))
          (E.input_ (cLeuronMod $ DeleteCategory 0))
      ) leuron.categories



  -- Splits

--  , input_Label "Splits" "Splits" "" P.InputText  (E.input (AddSplits <<< decode))

{-
TODO FIXME
  , H.div_ $
      map (\split ->
        input_DeleteEdit
          P.InputText
          (show split)
          (E.input (\new -> EditLeuronSplits split (decode new)))
          (E.input_ (RemoveLeuronSplits split))
      ) [] -- leuron.leuronSplits
-}



  -- Substitutions

--  , input_Label "Substitutions" "Substitutions" "" P.InputText  (E.input (AddLeuronSubstitutions <<< decode))

{-
TODO FIXME
  , H.div_ $
      map (\split ->
        input_DeleteEdit
          P.InputText
          (show split)
          (E.input (\new -> EditLeuronSubstitutions split (decode new)))
          (E.input_ (RemoveLeuronSubstitutions split))
      ) [] -- leuron.leuronSubstitutions



  -- Tags

TODO: add this back, removing for now
  , input_Label "Tags" "Tags" "" P.InputText  (E.input AddLeuronTags)

  , case leuron.leuronTags of
         Nothing -> H.div_ []
         (Just tagss) -> H.div_ $
            map (\tags ->
              input_DeleteEdit
                P.InputText
                tags
                (E.input (\new -> EditLeuronTags tags new))
                (E.input_ (RemoveLeuronTags tags))
              ) tagss



  -- Style

TODO FIXME
  , input_Label "Style" "Style" "" P.InputText  (E.input (cLeuronMod <<< AddStyle))

  , case leuron.leuronStyle of
         Nothing -> H.div_ []
         (Just styles) -> H.div_ $
            map (\style ->
              input_DeleteEdit
                P.InputText
                style
                (E.input (\new -> (cLeuronMod <<< EditStyle style new))
                (E.input_ (cLeuronMod <<< RemoveStyle style))
              ) styles



  -- SpecificTo

  , input_maybeField_DeleteEdit
      P.InputText
      "SpecificTo"
      leuron.leuronSpecificTo
      (E.input_ (SetLeuronSpecificTo ""))
      (E.input (\new -> SetLeuronSpecificTo new))
      (E.input_ RemoveLeuronSpecificTo)
-}


  , simpleInfoButton save (cLeuronMod $ Save m_leuron_id)

  , H.p_ $ map (\id_ -> H.a [P.href $ "/leurons/" <> show id_] [H.text $ show id_]) lst.ids

  ]
  where

  empty = H.h1_ [H.text "NONE"]

{-
  fact (Fact v) =
    H.p_ [
      H.h1_ [H.text "Fact"],
      textArea_Label "Fact" "fact" v.factText (E.input SetFact_FactText)
    ]
-}

{-
  factList (FactList v) =
    H.p_ [
      H.h1_ [H.text "FactList"],
      textArea_Label "Fact" "fact" v.factListFact (E.input SetFactList_Fact),
      textArea_LabelWithButton "FactList" "fact" st.leuronFactList_ListInput "Add" (E.input ModifyFactList_List) (E.input_AddFactList_List)
      , H.div_ $
          map (\fact ->
            textArea_DeleteEdit
              fact
              (E.input (\new -> EditFactList_List fact new))
              (E.input_ (RemoveFactList_List fact))
          ) v.factListList
    ]

  card (Card v) =
    H.p_ [
      H.h1_ [H.text "Card"],
      textArea_Label "Front" "front" v.cardFront (E.input SetCard_CardFront),
      textArea_Label "Back" "back" v.cardBack (E.input SetCard_CardBack)
    ]

  dcard (DCard v) =
    H.p_ [
      H.h1_ [H.text "DCard"],
      textArea_Label "Front" "front" v.dcardFront (E.input SetDCard_DCardFront),
      textArea_Label "Back" "back" v.dcardBack (E.input SetDCard_DCardBack)
    ]
-}


  leuron   = unwrapLeuronRequest leuron_req
  save     = maybe "Create" (const "Save") m_leuron_id
--  resource = unwrapResourceResponse st.resource
