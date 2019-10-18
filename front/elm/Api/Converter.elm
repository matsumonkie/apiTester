module Api.Converter exposing(..)

import Api.Client as Back
import BuilderApp.Model as Front

convertRequestNodesFromFrontToBack : List Front.RequestNode -> List Back.RequestNode
convertRequestNodesFromFrontToBack frontRequestNodes =
    let
        convertRequestNodeFromFrontToBack : Front.RequestNode -> Back.RequestNode
        convertRequestNodeFromFrontToBack frontRequestNode =
            case frontRequestNode of
                Front.RequestFolder folder ->
                    Back.RequestFolder
                        { name = folder.name
                        , children = convertRequestNodesFromFrontToBack folder.children
                        }
                Front.RequestFile file ->
                    Back.RequestFile
                        { name = file.name
                        , url = file.builder.url
                        }
    in
        List.map convertRequestNodeFromFrontToBack frontRequestNodes