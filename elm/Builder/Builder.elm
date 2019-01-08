module Builder.Builder exposing (..)

import Html exposing (Html, Attribute, div, input, text, a, select, option, button, textarea, p)
import Html.Attributes exposing (value, placeholder, href, disabled, class, id)
import Html.Events exposing (onInput, onClick, keyCode, on)
import Http
import Debug
import Url
import Json.Decode as Json

import Builder.Response
import Builder.Message exposing (Msg(..))
import Builder.RequestValidity
import Builder.Method exposing (Model(..))
import Builder.Header
import Builder.Url
import Builder.Body
import Builder.Tree
import Builder.Model exposing (Model(..))

defaultModel : Model
defaultModel =
  { name = "no name"
  , url = "swapi.co/api/people/1"
  , scheme = "HTTP"
  , method = Get
  , headers = []
  , body = ""
  , validity = { urlValid = False, httpHeadersValid = True }
  , response = Nothing
  }

init : () -> (Model, Cmd Msg)
init _ = (defaultModel, Cmd.none)

update : Msg
       -> (Builder.Url.Model, Builder.RequestValidity.Model, Maybe Builder.Response.Model)
       -> ((Builder.Url.Model, Builder.RequestValidity.Model, Maybe Builder.Response.Model), Cmd Msg)
update msg (model, validity, mHttpResponse) =
  case msg of
    UpdateUrl url ->
      case Builder.Url.parseUrl model url of
        Just u -> ( ( { model | url = url }
                    , { validity | urlValid = True }
                    , mHttpResponse)
                  , Cmd.none)
        Nothing -> ( ( { model | url = url }
                     , { validity | urlValid = False }
                     , mHttpResponse)
                   , Cmd.none)

    SetHttpMethod newMethod ->
      case newMethod of
        "GET" -> ( ({ model | httpMethod = Get, httpBody = Nothing }
                   , validity
                   , mHttpResponse)
                 , Cmd.none)
        _ -> ( ({ model | httpMethod = Post }
               , validity
               , mHttpResponse)
             , Cmd.none)

    SetHttpScheme scheme ->
      case scheme of
        "HTTP" -> ( ({ model | httpScheme = "HTTP" }
                    , validity
                    , mHttpResponse)
                  , Cmd.none)
        _ -> ( ({ model | httpScheme = "HTTPS" }
               , validity
               , mHttpResponse)
             , Cmd.none)

    GetHttpResponse result ->
      ((model, validity, Just result), Cmd.none)

    UpdateHeaders rawHeaders ->
      case Builder.Header.parseHeaders rawHeaders of
        Just httpHeaders ->
          ( ( { model | httpHeaders = httpHeaders }
            , { validity | httpHeadersValid = True }
            , mHttpResponse)
          , Cmd.none)
        Nothing ->
          ( (model
            , { validity | httpHeadersValid = False }
            , mHttpResponse)
          , Cmd.none )

    RunHttpRequest ->
      let
        httpRequest = Http.request
          { method = Builder.Method.toString model.httpMethod
          , headers = List.map Builder.Header.mkHeader model.httpHeaders
          , url = Builder.Url.fullUrl model
          , body = Http.emptyBody
          , expect = Http.expectString GetHttpResponse
          , timeout = Nothing
          , tracker = Nothing
          }
      in ((model, validity, mHttpResponse), httpRequest)

    SetHttpBody body ->
      ( ({ model | httpBody = Just body }, validity, mHttpResponse), Cmd.none )

-- VIEW

view : Model -> Html Msg
view model =
  div [ id "builder" ]
    [ Builder.Url.view (model, httpRequestValidity)
    , Builder.Header.view httpRequestValidity
    , Builder.Body.view model.httpMethod
    , Builder.Response.view mHttpResponse
    ]
