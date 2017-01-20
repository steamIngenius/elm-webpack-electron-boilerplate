module Main exposing (..)

import Html exposing (Html, text, div, h2, button)
import Html.Events exposing (onClick)


-- Model


type alias Model =
    Int


type Msg
    = Increment
    | Decrement



-- View


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , h2 [] [ text (toString model) ]
        , button [ onClick Increment ] [ text "+" ]
        ]



-- Update


update : Msg -> Model -> Model
update msg model =
    case msg of
        Decrement ->
            model - 1

        Increment ->
            model + 1



-- Main entry


main =
    Html.beginnerProgram
        { model = 0
        , view = view
        , update = update
        }
