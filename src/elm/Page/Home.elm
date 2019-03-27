module Page.Home exposing (view)

import Html exposing (Html, code, div, h1, h4, main_, strong, text)
import Html.Attributes exposing (class, tabindex)



-- VIEW


view : Html msg
view =
    main_ [ class "container--fluid", tabindex -1 ]
        [ h1 [ class "row justify-content-center u-margin-top-xl" ] [ text "ZALORA Style" ]
        , h4 [ class "row justify-content-center u-text-center" ] [ text "A responsive, mobile-first front-end component library designed for ZALORA." ]
        , div [ class "divider" ] []
        , div [ class "row" ]
            [ div [ class "col-sm-4 col-lg" ]
                [ h4 [] [ text "Installation" ]
                , div []
                    [ text "Install @zalora/style's source files via npm. The installed package also includes the original SASS and demostration HTML for building the project."
                    , code [] [ text "$ npm install @zalora/style" ]
                    ]
                ]
            , div [ class "col-sm-4 col-lg" ]
                [ h4 [] [ text "Usage" ]
                , div []
                    [ text "To use @zalora/style you can inject the"
                    , strong [] [ text "style.css" ]
                    , text "into your html file."
                    , div [] [ text "Or you can import @zalora/style into your js file as a css module" ]
                    , code []
                        [ text "import Style from '@zalora/style'" ]
                    ]
                ]
            , div [ class "col-sm-4 col-lg" ] [ h4 [] [ text "React Components" ], text "Also available in React. The documentation for style-react will come soon." ]
            ]
        ]
