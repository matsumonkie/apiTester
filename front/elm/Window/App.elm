module Window.App exposing (..)

import Window.Model exposing (..)
import Window.Message exposing (..)
import Window.StateHandler exposing (..)

import BuilderApp.App as BuilderApp
import BuilderApp.Model as BuilderApp
import BuilderApp.Message as BuilderApp
import BuilderApp.App as BuilderApp
import BuilderApp.Message as BuilderApp

import BuilderApp.Builder.App as Builder
import BuilderApp.Builder.Model as Builder
import BuilderApp.Builder.Message as Builder
import BuilderApp.Builder.App as Builder
import BuilderApp.Builder.Message as Builder

import BuilderApp.BuilderTree.View as BuilderTree
import BuilderApp.BuilderTree.Model as BuilderTree
import BuilderApp.BuilderTree.Message as BuilderTree
import BuilderApp.BuilderTree.App as BuilderTree

import Postman.View as Postman
import Postman.Model as Postman
import Postman.Message as Postman
import Postman.App as Postman

import EnvApp.View as EnvApp
import EnvApp.Model as EnvApp
import EnvApp.Message as EnvApp
import EnvApp.App as EnvApp

import EnvApp.EnvNav.View as EnvNav
import EnvApp.EnvNav.Model as EnvNav
import EnvApp.EnvNav.Message as EnvNav
import EnvApp.EnvNav.App as EnvNav
import EnvApp.EnvNav.Util as EnvNav

import BuilderApp.EnvSelection.View as EnvSelection
import BuilderApp.EnvSelection.Model as EnvSelection
import BuilderApp.EnvSelection.Message as EnvSelection
import BuilderApp.EnvSelection.App as EnvSelection

import BuilderApp.WorkspaceSelection.App as WorkspaceSelection

import RequestRunner.App as RequestRunner
import RequestRunner.Message as RequestRunner
import RequestRunner.Model as RequestRunner
import RequestRunner.Util as RequestRunner

import MainNavBar.Model as MainNavBar
import MainNavBar.View as MainNavBar
import MainNavBar.Message as MainNavBar
import MainNavBar.App as MainNavBar

import VarApp.Model as VarApp
import VarApp.View as VarApp
import VarApp.Message as VarApp
import VarApp.App as VarApp

import WorkspaceApp.Model as WorkspaceApp
import WorkspaceApp.View as WorkspaceApp
import WorkspaceApp.Message as WorkspaceApp
import WorkspaceApp.App as WorkspaceApp

import Util.Flip exposing (..)
import Util.List as List
import List.Extra as List

import Curl.Util as Curl

import Window.View exposing(..)
import Window.Model exposing(..)
import Window.Util exposing(..)

init : () -> (Model, Cmd Msg)
init _ =
  (defaultModel, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        BuilderTreeMsg subMsg ->
            let
                newBuildersAppModel newBuilderTree =
                    replaceBuilder model.workspaceSelection.selectedWorkspaceIdx model.buildersAppModel newBuilderTree
            in
                case getSelectedBuilder model of
                    Just builderApp ->
                        case BuilderTree.update subMsg builderApp.builderTreeModel of
                            (newBuilderTreeModel, newMsg) ->
                                let
                                    formerBuildersAppModel = model.buildersAppModel
                                in
                                    ( { model | buildersAppModel = newBuildersAppModel { builderApp | builderTreeModel = newBuilderTreeModel } }
                                    , Cmd.map BuilderTreeMsg newMsg
                                    )
                    Nothing -> (model, Cmd.none)

        EnvSelectionMsg subMsg ->
            case EnvSelection.update subMsg model.selectedEnvModel of
                (newSelectedEnvModel, newMsg) ->
                    ( { model | selectedEnvModel = newSelectedEnvModel }
                    , Cmd.map EnvSelectionMsg newMsg
                    )

        WorkspaceSelectionMsg subMsg ->
            case WorkspaceSelection.update subMsg model.workspaceSelection of
                (newWorkspaceSelection, newMsg) ->
                    ( { model | workspaceSelection = newWorkspaceSelection }
                    , Cmd.map WorkspaceSelectionMsg newMsg
                    )

        BuilderAppMsg subMsg ->
            case subMsg of
                BuilderApp.BuilderMsg (Builder.AskRun builder) ->
                    case EnvNav.getSelectedEnvInfo model.envNavModel of
                        Just envInfo ->
                            case RequestRunner.update (RequestRunner.Run envInfo.env model.varAppModel builder) Nothing of
                              (_, runnerSubMsg) -> (model, Cmd.map RequestRunnerMsg runnerSubMsg)

                        Nothing ->
                            (model, Cmd.none)

                BuilderApp.BuilderMsg (Builder.ShowRequestAsCurl builder) ->
                    case EnvNav.getSelectedEnvInfo model.envNavModel of
                        Just envInfo ->
                            let
                                requestInput = RequestRunner.buildRequestInput envInfo.env model.varAppModel builder
                            in
                                case Debug.log "request" (Curl.showRequestAsCurl requestInput) of
                                    (_) -> (model, Cmd.none)

                        Nothing ->
                            (model, Cmd.none)

                _ ->
                    let
                        newBuildersAppModel newBuilder =
                            replaceBuilder model.workspaceSelection.selectedWorkspaceIdx model.buildersAppModel newBuilder
                    in
                        case getSelectedBuilder model of
                            Just builderApp ->
                                case BuilderApp.update subMsg builderApp of
                                    (newBuilderTree, newMsg) ->
                                        ( { model | buildersAppModel = newBuildersAppModel newBuilderTree }
                                        , sendSaveTabRequest newBuilderTree.builderTreeModel
                                        )
                            Nothing -> (model, Cmd.none)

        SaveBuilderTreeResponse foo ->
            (model, Cmd.none)

        EnvNavMsg subMsg ->
            case EnvNav.update subMsg model.envNavModel of
                (newEnvNavModel, newMsg) ->
                    let
                        selectedEnvModel = model.selectedEnvModel
                        newSelectedEnvModel = { selectedEnvModel | envs = List.map .name newEnvNavModel.envs }
                    in
                        ( { model | envNavModel = newEnvNavModel, selectedEnvModel = newSelectedEnvModel }
                        , Cmd.map EnvNavMsg newMsg
                        )

        PostmanMsg subMsg ->
            case Postman.update subMsg model.postmanModel of
                {-(Just newBuilderTree, newMsg) ->
                    let
                        newBuilderTreeModel =
                            { selectedBuilderIndex = Nothing
                            , displayedBuilderIndexes = []
                            , tree = newBuilderTree
                            , displayedNodeMenuIndex = Nothing
                            }
                        formerBuildersAppModel = model.buildersAppModel
                        newBuilderAppModel = { formerBuilderAppModel | builderTreeModel = newBuilderTreeModel }
                    in
                        ( { model | builderAppModel = newBuilderAppModel }, Cmd.map PostmanMsg newMsg)
-}
                (_, _) -> (model, Cmd.none)
--                (Nothing, newMsg) -> (model, Cmd.none)


        RequestRunnerMsg subMsg ->
            (model, Cmd.none)
      {-
      case (subMsg, mBuilder model.builderAppModel, model.builderAppModel.displayedBuilderIndexes) of
        (RequestRunner.GetResponse response, Just builder, builderIndexes) ->
          let
            (updatedBuilder, cmdBuilder) = (Builder.update (Builder.GiveResponse response) builder)
            updateNode : BuilderTree.Node -> BuilderTree.Node
            updateNode oldNode =
              case oldNode of
                BuilderTree.File { name } -> BuilderTree.File { name = name, builder = updatedBuilder, showRenameInput = False }
                _ -> oldNode
            newBuilderTree = BuilderTree.modifyNode updateNode model.builderAppModel.tree 1 --builderIdx
            oldBuilderTreeModel = model.builderAppModel
            newBuilderTreeModel = { oldBuilderTreeModel | tree = newBuilderTree }
          in
            ( { model | builderAppModel = newBuilderTreeModel }, Cmd.map BuilderMsg cmdBuilder)
        _ -> (model, Cmd.none)-}

        EnvAppMsg subMsg ->
            case EnvApp.update subMsg model.envModel of
                (newEnvApp, newMsg) ->
                    ( { model | envModel = newEnvApp }, Cmd.map EnvAppMsg newMsg)

        MainNavBarMsg subMsg ->
            case MainNavBar.update subMsg model.mainNavBarModel of
                (newMainNavBarModel, newMsg) ->
                    ( { model | mainNavBarModel = newMainNavBarModel }
                    , Cmd.map MainNavBarMsg newMsg
                    )

        VarAppMsg subMsg ->
            case VarApp.update subMsg model.varAppModel of
                (newVarAppModel, newMsg) ->
                    ( { model | varAppModel = newVarAppModel }
                    , Cmd.map VarAppMsg newMsg
                    )

        WorkspaceAppMsg subMsg ->
            case WorkspaceApp.update subMsg model.workspaceAppModel of
                (newWorkspaceAppModel, newMsg) ->
                    let
                        formerWorkspaceSelection = model.workspaceSelection
                        newWorkspaceSelection =
                            { formerWorkspaceSelection | names = List.map Tuple.first newWorkspaceAppModel }
                    in
                    ( { model
                          | workspaceAppModel = newWorkspaceAppModel
                          , workspaceSelection = newWorkspaceSelection
                      }
                    , Cmd.map WorkspaceAppMsg newMsg
                    )

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none
