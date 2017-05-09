module Fullscreen exposing (..)

import Dict exposing (Dict)
import Heatmap
import Heatmap.Gradient as Heatmap
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode as Json exposing (Decoder)
import Svg exposing (Svg)
import Svg.Attributes
import Svg.Events


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = model
        , update = update
        , view = view
        }


type alias Model =
    { points : List Heatmap.Point
    , radius : Float
    , blur : Float
    , gradient : ( String, Heatmap.Gradient )
    }


type Msg
    = AddPoint Heatmap.Point
    | ClearPoints
    | SetRadius Float
    | SetBlur Float
    | SetGradient String


model : Model
model =
    { points = []
    , radius = 25
    , blur = 15
    , gradient = ( "Visible Spectrum", Heatmap.visibleSpectrum )
    }


gradients : Dict String Heatmap.Gradient
gradients =
    Dict.fromList
        [ ( "Black Aqua White", Heatmap.blackAquaWhite )
        , ( "Blue Red", Heatmap.blueRed )
        , ( "Color Spectrum", Heatmap.colorSpectrum )
        , ( "Deep Sea", Heatmap.deepSea )
        , ( "Incandescent", Heatmap.incandescent )
        , ( "Heated Metal", Heatmap.heatedMetal )
        , ( "Stepped Colors", Heatmap.steppedColors )
        , ( "Sunrise", Heatmap.sunrise )
        , ( "Visible Spectrum", Heatmap.visibleSpectrum )
        ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        AddPoint point ->
            { model | points = point :: model.points }

        ClearPoints ->
            { model | points = [] }

        SetRadius newRadius ->
            { model | radius = newRadius }

        SetBlur newBlur ->
            { model | blur = newBlur }

        SetGradient name ->
            let
                ( gradientName, gradient ) =
                    Dict.get name gradients
                        |> Maybe.map (\g -> ( name, g ))
                        |> Maybe.withDefault model.gradient
            in
                { model | gradient = ( gradientName, gradient ) }


view : Model -> Html Msg
view model =
    Html.div []
        [ Svg.svg
            [ Svg.Attributes.height "100%"
            , Svg.Attributes.width "100%"
            , Svg.Attributes.style "position: fixed; top: 0; bottom: 0;"
            , Svg.Events.on "mousemove"
                (Json.map AddPoint clientPosition)
            ]
            [ Heatmap.view
                (heatmapConfig model)
                model.points
            ]
        , Html.div
            [ Html.Attributes.style
                [ ( "position", "relative" )
                , ( "padding", "2px 16px" )
                , ( "margin", "32px" )
                , ( "background", "rgba(0,0,0,0.1)" )
                , ( "border-radius", "2px" )
                , ( "font-family", "sans-serif" )
                ]
            ]
            [ Html.div
                [ Html.Attributes.style
                    [ ( "display", "flex" )
                    , ( "justify-content", "space-around" )
                    , ( "align-items", "flex-end" )
                    ]
                ]
                [ Html.label []
                    [ Html.p [] [ Html.text "Radius" ]
                    , Html.input
                        [ Html.Attributes.type_ "range"
                        , Html.Attributes.min "1"
                        , Html.Attributes.max "50"
                        , Html.Attributes.value (toString model.radius)
                        , Html.Events.on "input" (Json.map SetRadius <| targetValueFloat model.radius)
                        ]
                        []
                    ]
                , Html.label []
                    [ Html.p [] [ Html.text "Blur" ]
                    , Html.input
                        [ Html.Attributes.type_ "range"
                        , Html.Attributes.min "1"
                        , Html.Attributes.max "50"
                        , Html.Attributes.value (toString model.blur)
                        , Html.Events.on "input" (Json.map SetBlur <| targetValueFloat model.blur)
                        ]
                        []
                    ]
                , Html.label []
                    [ Html.p [] [ Html.text "Gradient" ]
                    , Html.select
                        [ Html.Events.on "change"
                            (Json.map SetGradient Html.Events.targetValue)
                        ]
                        (List.map
                            (\name ->
                                Html.option
                                    [ Html.Attributes.selected
                                        (name == Tuple.first model.gradient)
                                    ]
                                    [ Html.text name ]
                            )
                            (Dict.keys gradients)
                        )
                    ]
                , Html.button
                    [ Html.Events.onClick ClearPoints ]
                    [ Html.text "Clear" ]
                ]
            , Html.p
                [ Html.Attributes.style
                    [ ( "text-align", "center" )
                    ]
                ]
                [ Html.small [] [ Html.text "Move your mouse to add points. But be careful, many points will slow down the rendering." ] ]
            ]
        ]


heatmapConfig : Model -> Heatmap.Config Heatmap.Point
heatmapConfig { gradient, radius, blur } =
    Heatmap.config
        { toPoint = identity, gradient = Tuple.second gradient }
        |> Heatmap.withRadius radius
        |> Heatmap.withBlur blur


targetValueFloat : Float -> Decoder Float
targetValueFloat fallback =
    Html.Events.targetValue
        |> Json.andThen
            (\value ->
                Json.succeed <|
                    case String.toFloat value of
                        Ok f ->
                            f

                        Err _ ->
                            fallback
            )


clientPosition : Decoder Heatmap.Point
clientPosition =
    Json.map3 Heatmap.Point
        (Json.field "clientX" Json.float)
        (Json.field "clientY" Json.float)
        (Json.succeed 1)
