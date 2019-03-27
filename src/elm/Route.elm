module Route exposing (Route(..), fromUrl, href)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, map, oneOf, s, string, top)



-- ROUTING


type Route
    = Home
    | Articles
    | Article String
    | Playground
    | NotFound


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Home top
        , map Articles (s "articles")
        , map Article (s "articles" </> string)
        , map Playground (s "playground")
        ]


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


fromUrl : Url -> Route
fromUrl url =
    let
        route =
            { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
                |> Parser.parse parser
    in
    case route of
        Just value ->
            value

        Nothing ->
            NotFound


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                Articles ->
                    [ "articles" ]

                Article name ->
                    [ "articles", name ]

                Playground ->
                    [ "playground" ]

                NotFound ->
                    []
    in
    "#/" ++ String.join "/" pieces
