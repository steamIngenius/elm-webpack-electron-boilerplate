port module Main exposing (..)

import Html exposing (Html, text, div, h2, button, input, form, label)
import Html.Attributes exposing (type_, style, placeholder, value)
import Html.Events exposing (onSubmit, onInput)
import Http


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
        ""
        ""
        ""
        ""
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
            ]
            []
        , input
            [ onInput SetPort
            , placeholder "[port]"
            ]
            []
        , input
            [ onInput SetUsername
            , placeholder "Username"
            ]
            []
        , input
            [ onInput SetPassword
            , type_ "password"
            , placeholder "Password"
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
    | LoginResponse (Result Http.Error String)


port encrypt : String -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "updating state..." ( msg, model )
    in
        case msg of
            Login ->
                ( model, encrypt model.password )

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

            Encrypt ciphertext ->
                let
                    _ =
                        Debug.log "Got something back from js: " ciphertext
                in
                    ( model, Cmd.none )

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
