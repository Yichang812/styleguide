module Route exposing (Route(..), buildPath, parser, toRoute)

import Url
import Url.Builder exposing (Root(..), custom, relative)
import Url.Parser exposing ((</>), Parser, fragment, map, oneOf, parse, s, string, top)


type Route
    = PagesRoute
    | PageRoute String (Maybe String)
    | NotFound


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map PagesRoute top
        , map PageRoute (top </> Url.Parser.string </> fragment identity)
        ]


toRoute : String -> Route
toRoute articleName =
    case Url.fromString articleName of
        Nothing ->
            NotFound

        Just url ->
            Maybe.withDefault NotFound (parse parser url)


buildPath : Route -> String
buildPath route =
    case route of
        PagesRoute ->
            ""

        PageRoute articlePath fragment ->
            case fragment of
                Just tag ->
                    custom Relative [ articlePath ] [] (Just tag)

                Nothing ->
                    relative [ articlePath ] []

        NotFound ->
            relative [ "notfound" ] []
