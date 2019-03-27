module Util exposing (loading, menuIcon)

import Html exposing (Html, div)
import Html.Attributes exposing (class)


menuIcon : Html msg
menuIcon =
    div [ class "menuIcon" ]
        [ div [] []
        , div [] []
        , div [] []
        ]


loading : Html msg
loading =
    div [ class "loadingIcon" ]
        [ div [] []
        , div [] []
        , div [] []
        , div [] []
        , div [] []
        , div [] []
        , div [] []
        , div [] []
        ]
