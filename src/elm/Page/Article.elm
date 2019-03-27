module Page.Article exposing (Model, Msg, codeSnippet, init, innerCode, update, view)

import AppState exposing (AppState(..))
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Html exposing (Attribute, Html, a, button, div, input, label, li, main_, text, ul)
import Html.Attributes exposing (class, classList, for, id, property, style, type_)
import Html.Events exposing (onClick, onInput)
import Http exposing (..)
import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Encode exposing (string)
import Markdown exposing (toHtml)
import Markdown.Block as Block exposing (Block, CodeBlock, defaultHtml)
import Markdown.Config exposing (HtmlOption(..), Options)
import Maybe exposing (withDefault)
import Route exposing (href)
import String exposing (contains)
import Url.Builder exposing (absolute)
import Util exposing (loading, menuIcon)



-- MODEL


type alias Model =
    { title : Maybe String
    , content : Maybe String
    , fileList : List String
    , shownFileList : List String
    , appState : AppState Http.Error
    , compact : Bool
    }



-- INIT


init : Maybe String -> ( Model, Cmd Msg )
init maybeTitle =
    let
        decoder : Decoder (List String)
        decoder =
            Decode.list (Decode.map (String.replace ".md" "") Decode.string)
    in
    ( { title = maybeTitle
      , content = Nothing
      , fileList = []
      , shownFileList = []
      , appState = AppState.init
      , compact = False
      }
    , Http.get
        { url = "/pages/staticFilesMap.json"
        , expect = Http.expectJson InitView decoder
        }
    )



-- VIEW


view : Model -> Html Msg
view model =
    let
        { appState } =
            model
    in
    case appState of
        InitLoading ->
            main_ [] [ loading ]

        Loaded maybeError ->
            main_ []
                [ case maybeError of
                    Just error ->
                        text <| "Error: " ++ Debug.toString error

                    Nothing ->
                        main_ []
                            [ div [ class "row u-padding-horizontal-m" ]
                                [ sideMenu model
                                , article <| .content model
                                ]
                            ]
                ]

        Loading ->
            main_ [] [ loading ]

        LoadingError error ->
            main_ [] [ text <| Debug.toString error ]


sideMenu : Model -> Html Msg
sideMenu model =
    div [ class "col-sm-4 col-md-2 col-l-2 sideMenu" ]
        [ div [ class "row justify-content-between" ]
            [ div [ class "textField col" ]
                [ input [ id "searchArticle", type_ "text", onInput SearchArticle ] []
                , label [ for "searchArticle" ] [ text "Search ..." ]
                ]
            , button [ class "btn btn--outline articleListToggle", onClick ToggleArticleList ] [ Util.menuIcon ]
            ]
        , List.map (\s -> listItem s (.title model)) (.shownFileList model)
            |> ul [ class "list collapse__target articleList", showList <| .compact model ]
        ]


listItem : String -> Maybe String -> Html msg
listItem fileName activeFile =
    li [ classList [ ( "list__item--single", True ), ( "u-font-weight-bold", fileName == Maybe.withDefault "" activeFile ) ] ]
        [ a [ class "u-text-grey-100", Route.href <| Route.Article fileName ] [ text fileName ] ]


article : Maybe String -> Html msg
article content =
    let
        options : Options
        options =
            { softAsHardLineBreak = False
            , rawHtml = ParseUnsafe
            }

        customHtmlBlock : Block b i -> List (Html msg)
        customHtmlBlock block =
            case block of
                Block.CodeBlock codeblock codestr ->
                    [ div [ class "example" ]
                        [ div [ class "example__preview" ] <| Markdown.toHtml (Just options) codestr
                        , div [ class "example__codeblock" ] [ codeSnippet [ innerCode codestr ] ]
                        ]
                    ]

                _ ->
                    Block.defaultHtml
                        (Just customHtmlBlock)
                        Nothing
                        block
    in
    withDefault "" content
        |> Block.parse (Just options)
        |> List.map customHtmlBlock
        |> List.concat
        |> div [ class "col-sm-4 col-md-6 col-l-10" ]


codeSnippet : List (Html.Attribute msg) -> Html msg
codeSnippet attributes =
    Html.node "code-snippet" attributes []


innerCode : String -> Html.Attribute msg
innerCode code =
    Html.Attributes.property "innerCode" <|
        Json.Encode.string code



-- UPDATE


type Msg
    = InitView (Result Http.Error (List String))
    | SearchArticle String
    | FileLoaded (Result Http.Error String)
    | ToggleArticleList


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        { appState, fileList, title, compact } =
            model
    in
    case msg of
        InitView data ->
            case data of
                Ok value ->
                    let
                        cmd =
                            case title of
                                Nothing ->
                                    Cmd.none

                                Just fileName ->
                                    Http.get
                                        { url = "/pages/" ++ fileName ++ ".md"
                                        , expect = expectString FileLoaded
                                        }
                    in
                    ( { model | fileList = value, shownFileList = value, appState = AppState.toSuccess appState }, cmd )

                Err error ->
                    ( { model | appState = AppState.toFailure error appState }, Cmd.none )

        FileLoaded data ->
            case data of
                Ok file ->
                    ( { model | content = Just file, appState = AppState.toSuccess appState }, Cmd.none )

                Err error ->
                    ( { model | content = Just "Fail to load content", appState = AppState.toFailure error appState }, Cmd.none )

        SearchArticle input ->
            ( { model | shownFileList = fileFilter input fileList }, Cmd.none )

        ToggleArticleList ->
            ( { model | compact = not compact }, Cmd.none )


fileFilter : String -> List String -> List String
fileFilter input fileList =
    List.filter (\file -> contains input file) fileList


showList : Bool -> Attribute msg
showList display =
    case display of
        True ->
            style "height" "100%"

        False ->
            style "height" "0"
