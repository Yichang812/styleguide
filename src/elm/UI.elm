module UI exposing (loading, navBar)

import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class)


navBar : Html msg
navBar =
    div [ class "navbar" ]
        [ h1 [] [ text "Zalora Styleguide" ] ]


loading : Html msg
loading =
    div [ class "loading__icon" ]
        [ div [] []
        , div [] []
        , div [] []
        , div [] []
        , div [] []
        , div [] []
        , div [] []
        , div [] []
        ]
