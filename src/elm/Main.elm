module Main exposing (Model, Msg(..), init, main, update, view)

-- import CodeMirror exposing (..)

import AppState exposing (AppState(..))
import Browser
import Browser.Navigation as Nav exposing (Key)
import CodeEditor exposing (playground)
import Dict exposing (Dict)
import Html exposing (Attribute, Html, a, code, div, input, li, pre, section, text, textarea, ul)
import Html.Attributes exposing (attribute, class, href, id, placeholder, type_)
import Html.Events exposing (on, onClick, onInput, stopPropagationOn, targetValue)
import Http
import Json.Decode as Decode exposing (Decoder, dict, list, string)
import Json.Decode.Pipeline exposing (required)
import Markdown exposing (toHtml)
import Markdown.Block as Block exposing (Block, CodeBlock, defaultHtml)
import Markdown.Config exposing (HtmlOption(..), Options)
import Port exposing (highlight, onUrlChange, setPreview)
import Route exposing (Route(..), buildPath)
import UI exposing (loading)
import Url exposing (Url, fromString)
import Url.Builder as Builder



-- import String exposing (String, repl)
---- MODEL ----


type alias Model =
    { code : String
    , activeFileContent : Maybe String
    , activeFileName : Maybe String
    , fileList : Dict String (List File)
    , shownFileList : Dict String (List File)
    , appState : AppState Http.Error
    , url : Url
    , key : Key
    }


type alias File =
    { name : String
    , path : String
    }



---- VIEW ----


view : Model -> Browser.Document Msg
view model =
    let
        { appState } =
            model

        body =
            case appState of
                InitLoading ->
                    div [] [ UI.loading ]

                Loaded maybeError ->
                    div []
                        [ case maybeError of
                            Just error ->
                                text <| "Error: " ++ Debug.toString error

                            Nothing ->
                                text ""
                        , viewContainer model
                        ]

                Loading ->
                    div [] [ UI.loading ]

                LoadingError error ->
                    div [] [ text <| Debug.toString error ]
    in
    { title = "Styleguide"
    , body = [ body ]
    }


viewContainer : Model -> Html Msg
viewContainer model =
    div [ class "grid-container" ]
        [ UI.navBar
        , sideMenu model
        , mainContent model
        ]


sideMenu : Model -> Html Msg
sideMenu model =
    div [ class "sidebar" ]
        [ div [ class "sidebar__search" ]
            [ input [ class "sidebar__search--input", type_ "input", placeholder "Type to search", onInput SearchArticle ] [] ]
        , sideMenuList model
        ]


sideMenuList : Model -> Html Msg
sideMenuList model =
    ul [] <| List.map (\s -> categoryList s (.activeFileName model)) (Dict.toList <| .shownFileList model)


categoryList : ( String, List File ) -> Maybe String -> Html Msg
categoryList ( category, fileList ) activeFile =
    let
        isActiveFile : File -> Maybe String -> Bool
        isActiveFile file activeFileName =
            .name file == Maybe.withDefault "" activeFileName
    in
    div []
        [ a [ class "sidebar__category" ] [ text category ]
        , ul [] <|
            List.map (\i -> categoryItem i <| isActiveFile i activeFile) fileList
        ]


categoryItem : File -> Bool -> Html Msg
categoryItem file isActive =
    let
        className =
            if isActive then
                "sidebar__filename--active"

            else
                "sidebar__filename"
    in
    li [] [ a [ href <| .path file, class className, attribute "data-path" <| .path file ] [ text <| .name file ] ]


mainContent : Model -> Html Msg
mainContent model =
    div [ class "main" ] <|
        case .activeFileContent model of
            Just value ->
                [ article value
                , CodeEditor.playground (.code model) CodeChanged
                ]

            Nothing ->
                [ text "Welcome to our new styleguide!" ]


article : String -> Html msg
article doc =
    let
        options : Options
        options =
            { softAsHardLineBreak = False
            , rawHtml = ParseUnsafe
            }

        customHtmlBlock : Block b i -> List (Html msg)
        customHtmlBlock block =
            let
                toHtmlCodeblock str =
                    "```html\n" ++ str ++ "\n```"
            in
            case block of
                Block.CodeBlock codeblock codestr ->
                    [ div [ class "example" ]
                        [ div [ class "example__preview" ] <| Markdown.toHtml (Just options) codestr
                        , div [ class "example__codeblock" ] <| Markdown.toHtml Nothing (toHtmlCodeblock codestr)
                        ]
                    ]

                _ ->
                    Block.defaultHtml
                        (Just customHtmlBlock)
                        Nothing
                        block
    in
    doc
        |> Block.parse (Just options)
        |> List.map customHtmlBlock
        |> List.concat
        |> div [ class "article" ]



---- UPDATE ----


type Msg
    = InitView (Result Http.Error (Dict String (List File)))
      -- | SelectFile File
    | FileLoaded (Result Http.Error String)
    | CodeChanged String
    | SearchArticle String
    | UrlChanged Url
    | LinkClicked Browser.UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        { appState, fileList, url } =
            model
    in
    case msg of
        InitView data ->
            case data of
                Ok value ->
                    ( { model | fileList = value, shownFileList = value, appState = AppState.toSuccess appState }, Cmd.none )

                Err error ->
                    ( { model | appState = AppState.toFailure error appState }, Cmd.none )

        FileLoaded data ->
            case data of
                Ok file ->
                    ( { model | activeFileContent = Just file, shownFileList = fileList, appState = AppState.toSuccess appState }, highlight "test" )

                Err error ->
                    ( { model | activeFileContent = Just "Fail to load content", appState = AppState.toFailure error appState }, Cmd.none )

        CodeChanged code ->
            ( { model | code = code }, setPreview code )

        SearchArticle input ->
            ( { model | shownFileList = filterCategoriesAndFiles input fileList }, Cmd.none )

        UrlChanged newUrl ->
            ( { model | url = newUrl }, loadFile url )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal requestUrl ->
                    ( model, Nav.pushUrl model.key (Url.toString requestUrl) )

                Browser.External href ->
                    ( model, Nav.load href )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



---- INIT ----


init : () -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        fileDecoder : Decoder File
        fileDecoder =
            Decode.succeed File
                |> required "name" Decode.string
                |> required "path" Decode.string

        cmd =
            Decode.dict (Decode.list fileDecoder)
                |> Http.get "/pages/categoryPostMap.json"
                |> Http.send InitView
    in
    ( { code = "<!-- try to write some html code here -->"
      , activeFileContent = Nothing
      , activeFileName = Nothing
      , fileList = Dict.fromList []
      , shownFileList = Dict.fromList []
      , appState = AppState.init
      , url = url
      , key = key
      }
    , cmd
    )


loadFile : Url -> Cmd Msg
loadFile url =
    if .path url /= "" then
        Http.getString (Url.toString url)
            |> Http.send FileLoaded

    else
        Cmd.none


filterCategoriesAndFiles : String -> Dict String (List File) -> Dict String (List File)
filterCategoriesAndFiles keyword fileList =
    let
        map : String -> ( String, List File ) -> ( String, List File )
        map input categoryFileMap =
            if String.contains (String.toLower input) (String.toLower <| Tuple.first categoryFileMap) then
                categoryFileMap

            else
                Tuple.mapSecond (filterFile input) categoryFileMap

        filterFile input list =
            list
                |> List.filter (\f -> String.contains (String.toLower input) (String.toLower <| .name f))
    in
    Dict.toList fileList
        |> List.map (\list -> map keyword list)
        |> List.filter (\list -> List.length (Tuple.second list) /= 0)
        |> Dict.fromList



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
