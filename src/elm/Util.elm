module Util exposing (codeSnippet, loading, menuIcon)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Json.Encode exposing (string)


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


codeSnippet : String -> Html msg
codeSnippet code =
    Html.node "code-snippet" [ innerCode code ] []


innerCode : String -> Html.Attribute msg
innerCode code =
    Html.Attributes.property "innerCode" <|
        Json.Encode.string code
