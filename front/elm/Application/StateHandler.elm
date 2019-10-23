module Application.StateHandler exposing (..)

import Http
import Json.Encode as Json

import Application.Model exposing (..)
import Application.Message exposing (..)

import BuilderApp.Model as BuilderApp
import BuilderApp.Builder.Model as Builder
import BuilderApp.Builder.Method as Builder

toArray : List Json.Value -> Json.Value
toArray values = Json.list (\a -> a) values

nodeEncoder : BuilderApp.RequestNode -> Json.Value
nodeEncoder node =
  case node of
    BuilderApp.RequestFolder f -> folderEncoder f
    BuilderApp.RequestFile f -> fileEncoder f

fileEncoder : BuilderApp.File -> Json.Value
fileEncoder file =
  Json.object
    [ ("type", Json.string "file")
    , ("name", Json.string file.name)
    , ("builder", builderEncoder file.builder)
    ]

headerEncoder : Builder.Header -> Json.Value
headerEncoder (key, value) =
  Json.object [ (key, Json.string value) ]

builderEncoder : Builder.Model -> Json.Value
builderEncoder builder =
  Json.object
    [ ("name", Json.string builder.name)
    , ("url", Json.string builder.url)
    , ("method", Json.string (Builder.methodToString builder.method))
    , ("headers", List.map headerEncoder builder.headers |> toArray)
    , ("body", Json.string builder.body)
    ]

folderEncoder : BuilderApp.Folder -> Json.Value
folderEncoder folder =
  Json.object
    [ ("type", Json.string "folder")
    , ("name", Json.string folder.name)
    , ("open", Json.bool folder.open)
    , ("children", List.map nodeEncoder folder.children |> toArray)
    ]