port module Main exposing (..)

import Html exposing (Html, text, div, h2, button, input, form, label)
import Html.Attributes exposing (type_, style, placeholder, value)
import Html.Events exposing (onSubmit, onInput)
import Http
import Json.Encode as Encode
import Json.Decode as Decode


-- Model


type alias Model =
    { username : String
    , password : String
    , server : String
    , serverPort : String
    , sessionId : Maybe String
    , error : Maybe String
    }


initModel : Model
initModel =
    Model
        "usera"
        "a"
        "kitsune"
        "8090"
        Nothing
        Nothing


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    form
        [ onSubmit Login
        , style
            [ ( "display", "flex" )
            , ( "flex-direction", "column" )
            , ( "align-items", "center" )
            ]
        ]
        [ input
            [ onInput SetServer
            , placeholder "[host]"
            , value model.server
            ]
            []
        , input
            [ onInput SetPort
            , placeholder "[port]"
            , value model.serverPort
            ]
            []
        , input
            [ onInput SetUsername
            , placeholder "Username"
            , value model.username
            ]
            []
        , input
            [ onInput SetPassword
            , type_ "password"
            , placeholder "Password"
            , value model.password
            ]
            []
        , button [ type_ "Submit" ] [ text "Login" ]
        ]



-- Update


type Msg
    = Login
    | SetUsername String
    | SetPassword String
    | SetServer String
    | SetPort String
    | Encrypt String
    | PublicKey (Result Http.Error String)
    | SessionId (Result Http.Error String)
    | LoginResponse (Result Http.Error String)


port encrypt : ( String, String ) -> Cmd msg


getPublicKey : String -> String -> Cmd Msg
getPublicKey server serverPort =
    let
        url =
            "http://"
                ++ server
                ++ ":"
                ++ serverPort
                ++ "/api/v1/auth/public-key"

        request =
            Http.getString url

        cmd =
            Http.send PublicKey request
    in
        cmd


getSessionId : String -> String -> String -> String -> Cmd Msg
getSessionId server serverPort username password =
    let
        url =
            "http://"
                ++ server
                ++ ":"
                ++ serverPort
                ++ "/api/v1/auth/login"

        creds =
            [ ( "userName", (Encode.string username) )
            , ( "encryptedPassword", (Encode.string password) )
            ]

        body =
            Encode.object creds
                |> Http.jsonBody

        request =
            Http.request
                { body = body
                , expect = Http.expectJson (Decode.field "session" Decode.string)
                , headers = []
                , method = "POST"
                , timeout = Nothing
                , url = url
                , withCredentials = False
                }

        cmd =
            Http.send SessionId request
    in
        cmd


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "updating state..." ( msg, model )
    in
        case msg of
            Login ->
                ( model, getPublicKey model.server model.serverPort )

            SetUsername input ->
                ( { model
                    | username = input
                  }
                , Cmd.none
                )

            SetPassword input ->
                ( { model
                    | password = input
                  }
                , Cmd.none
                )

            SetPort input ->
                ( { model
                    | serverPort = input
                  }
                , Cmd.none
                )

            SetServer input ->
                ( { model
                    | server = input
                  }
                , Cmd.none
                )

            PublicKey (Ok key) ->
                let
                    _ =
                        Debug.log "Got this key: " key
                in
                    ( model, encrypt ( key, model.password ) )

            PublicKey (Err err) ->
                ( { model | error = Just (toString err) }, Cmd.none )

            SessionId (Ok id) ->
                let
                    _ =
                        Debug.log "Got this session: " id
                in
                    ( { model
                        | sessionId = Just id
                      }
                    , Cmd.none
                    )

            SessionId (Err err) ->
                ( { model | error = Just (toString err) }, Cmd.none )

            Encrypt ciphertext ->
                let
                    _ =
                        Debug.log "Got something back from js land: " ciphertext
                in
                    ( model
                    , getSessionId
                        model.server
                        model.serverPort
                        model.username
                        ciphertext
                    )

            _ ->
                ( model, Cmd.none )



-- Susbcriptions


subs : Model -> Sub Msg
subs model =
    encrypted Encrypt


port encrypted : (String -> msg) -> Sub msg



-- Main entry


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subs
        }
