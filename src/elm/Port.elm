port module Port exposing (highlight, onUrlChange, setPreview)


port highlight : String -> Cmd msg


port setPreview : String -> Cmd msg


port onUrlChange : (String -> msg) -> Sub msg
