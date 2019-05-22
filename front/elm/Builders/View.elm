module Builders.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Builders.Message exposing (..)
import Builders.Model exposing (..)

import Builder.View as Builder
import BuilderTree.Util as BuilderTree
import BuilderTree.Model as BuilderTree
import Util.List as List
import Util.Maybe as Maybe
import Builder.Model as Builder

view : Model -> Html Msg
view model =
  let
    builderTabsView = List.map (tabView model model.selectedBuilderIndex) model.displayedBuilderIndexes
    builderAppsView = List.map (builderView model) model.displayedBuilderIndexes
  in
    div [ id "builderPanel" ]
      [ ul [ id "buildersNavbar" ] builderTabsView
      , div [] builderAppsView
      ]

tabView : Model -> Maybe Int -> Int ->Html Msg
tabView model mSelectedIdx idx =
  let
    activeClass =
      case mSelectedIdx == Just idx of
        True -> "isActive"
        False -> ""
    savedView = a [ href "#" ] [ ]
    unsavedView file = a [ href "#", onClick (SaveTab idx) ] [ text "*" ]
    savingView file =
      case file.isSaved of
        True -> savedView
        False -> unsavedView file
  in
    case BuilderTree.findNode model.tree idx of
      Just (BuilderTree.File file)  ->
        li [ class activeClass ]
          [ a [ href "#", onClick (SelectTab idx) ] [ text (file.name) ]
          , savingView file
          , a [ href "#", onClick (CloseTab idx), class "closeBuilder" ] [ span [ class "fas fa-times" ] [] ]
          ]
      _ -> li [] []

builderView : Model -> Int -> Html Msg
builderView model idx =
  let
    mBuilder = BuilderTree.findBuilder model.tree idx
  in
    case mBuilder of
      Just builder ->
        div [ hidden (not (model.selectedBuilderIndex == Just idx)) ]
            [ Html.map BuilderMsg (Builder.view builder) ]
      Nothing -> div [] []
