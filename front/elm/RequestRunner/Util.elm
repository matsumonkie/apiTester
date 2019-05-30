module RequestRunner.Util exposing (..)

import Http
import Combine exposing (..)
import List.Extra as List

import Util.KeyValue.Model as KeyValue

import RequestRunner.Message exposing (..)
import RequestRunner.Model exposing (..)

import BuilderApp.Builder.Method as Builder
import BuilderApp.Builder.Header as Builder
import BuilderApp.Builder.Url as Builder
import BuilderApp.Builder.Model as Builder

import EnvApp.Model as EnvApp
import VarApp.Model as VarApp

buildRequest : EnvApp.Model -> VarApp.Model -> Builder.Model -> Cmd Msg
buildRequest env var builder =
  let
    httpRequest = Http.request
      { method = Builder.methodToString builder.method
      , headers = List.map Builder.mkHeader builder.headers
      , url = interpolate env var.vars builder.url
      , body = Http.emptyBody
      , expect = Http.expectString GetResponse
      , timeout = Nothing
      , tracker = Nothing
      }
  in
    httpRequest

interpolate : EnvApp.Model -> List(KeyValue.Model) -> String -> String
interpolate env var str =
  let
    build : TemplatedString -> String
    build templatedString =
      case templatedString of
        Sentence c -> c
        Key key ->
          case List.find (\(k, v) -> k == key) env of
            Just (_, value) -> value
            Nothing ->
                case List.find (\(k, v) -> k == key) var of
                    Just (_, value) -> value
                    Nothing -> key
  in
    case toRaw str of
      Ok result -> List.map build result |> List.foldr (++) ""
      Err errors -> Debug.log errors str

toRaw : String -> Result String (List TemplatedString)
toRaw str =
  case parse templatedStringParser str of
    Ok (_, _, result) ->
      Ok result

    Err (_, stream, errors) ->
      Err (String.join " or " errors)

type TemplatedString
    = Sentence String
    | Key String

templatedStringParser : Parser s (List TemplatedString)
templatedStringParser = many (or keyParser anychar)

anychar : Parser s TemplatedString
anychar = regex "." |> map Sentence

keyParser : Parser s TemplatedString
keyParser =
  let
    envKey : Parser s TemplatedString
    envKey = regex "([a-zA-Z]|[0-9])+" |> map Key
  in
    between (string "{{") (string "}}") envKey
