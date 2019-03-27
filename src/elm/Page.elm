module Page exposing (pageView)

import Browser
import Html exposing (Html, a, div, footer, img, li, small, text, ul)
import Html.Attributes as Attr exposing (alt, class, href, src)
import Route exposing (href)


pageView : { title : String, view : Html msg } -> Browser.Document msg
pageView { title, view } =
    { title = "Style -" ++ title
    , body = currentPage view
    }


currentPage : Html msg -> List (Html msg)
currentPage content =
    viewHeader :: content :: [ viewFooter ]


viewHeader : Html msg
viewHeader =
    div [ class "navbar align-items-center justify-content-start" ]
        [ a [ class "navbar__logo", Route.href Route.Home ] [ img [ src "/assets/primary_logo_white.png", alt "ZALORA" ] [] ]
        , ul [ class "navbar__nav" ]
            [ li [ class "navbar__navItem" ] [ a [ class "u-text-white", Route.href Route.Articles ] [ text "Documentation" ] ]
            , li [ class "navbar__navItem" ] [ a [ class "u-text-white", Route.href Route.Playground ] [ text "Playground" ] ]
            ]
        ]


viewFooter : Html msg
viewFooter =
    footer [ class "footer u-bg-grey-100 u-text-white" ]
        [ div [ class "row" ]
            [ div [ class "col" ] [ a [ class "u-text-white", Attr.href "https://github.com/zalora/style" ] [ text "Github" ] ]
            , div [ class "col" ] [ a [ class "u-text-white", Attr.href "https://github.com/zalora/style-react" ] [ text "Style-react" ] ]
            , div [ class "col" ] [ a [ class "u-text-white", Route.href <| Route.Article "color" ] [ text "Color" ] ]
            , div [ class "col" ] [ a [ class "u-text-white", Route.href <| Route.Article "principle" ] [ text "Design Priciple" ] ]
            ]
        , div [ class "row u-margin-top-l" ]
            [ div [ class "col u-text-micro" ] [ text "Currently v1.4.0. Released under the Apache License 2.0" ] ]
        ]
