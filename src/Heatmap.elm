module Heatmap
    exposing
        ( Config
        , Point
        , config
        , withMaxWeight
        , withRadius
        , withBlur
        , withIdSuffix
        , view
        )

{-| This library helps you to turn a list of weighted positions into a Svg based heatmap.

The general idea is based on [simpleheat](https://github.com/mourner/simpleheat), which uses a `canvas` implementation.

**Warning:** This is really not the fastest heatmap implementation, mainly because it's rendered in Svg. So it should probably not be used when the heatmap data or config changes a lot on user interaction and when render performance is critical.

# View
@docs view

# Configuration
@docs config, Config, Point, withMaxWeight, withRadius, withBlur, withIdSuffix
-}

import Color exposing (Color)
import Color.Gradient exposing (Palette)
import Color.Interpolate
import Dict exposing (Dict)
import Heatmap.Gradient as Gradient exposing (Gradient)
import Svg exposing (Svg)
import Svg.Attributes


-- CONFIG


{-| Configuration for the heatmap.

It describes the appearance of a heatmap and how to turn your data into heatmappable `Point`s.

**Note:** The `Config` does not belong in your `Model` as it contains a function to turn your data into a `Point`.
-}
type Config data
    = Config (ConfigInternal data)


type alias ConfigInternal data =
    { toPoint : data -> Point
    , gradient : Gradient
    , maxWeight : Float
    , radius : Float
    , blur : Float
    , idSuffix : Maybe String
    }


{-| A `Point` describes the importance at a given position in the heatmap.

The origin of the coordiante system is the top left corner.
The positive x-axis points towards the right, the positive y-axis points down.
Points are positioned without a unit identifier (that is *in user space* using *user units* in Svg speech).
-}
type alias Point =
    { x : Float
    , y : Float
    , weight : Float
    }


{-| Create the `Config` for a heatmap.

You need to define at least the colors of the heatmap as a `Gradient` and how to turn your `data` into a `Point`.

The `toPoint` function should return a normalized `weight` between `0` and `1` for a default configuration.
You can also use `maxWeight` to let the heatmap do the normalization.

Have a look at `Heatmap.Gradient` for some default gradients or how to create your own gradient.

    type alias Fire =
        { location : LatLng
        , risk : Int -- in %
        }

    toPoint : Fire -> Heatmap.Point
    toPoint fire =
        let
            {x, y} = project fire.location
        in
            { x = x
            , y = y
            , weight = toFloat fire.risk / 100
            }

    config : Config
    config =
        Heatmap.config
            { gradient =
                Heatmap.Gradient.heatedMetal
            , toPoint =
                (\p ->
                    let
                )
            }
-}
config : { toPoint : data -> Point, gradient : Gradient } -> Config data
config { toPoint, gradient } =
    Config
        { toPoint = toPoint
        , gradient = gradient
        , maxWeight = 1
        , radius = 25
        , blur = 15
        , idSuffix = Nothing
        }


{-| Set the maximum data weight (1 by default).

    myConfig
        |> withMaxWeight 256

The relative weight of a point in the data list to the maximum weight defines the intensity in the heatmap.
In other words, `point.weight / config.weight` sets the render opacity for a given point.
-}
withMaxWeight : Float -> Config data -> Config data
withMaxWeight maxWeight (Config configInternal) =
    Config
        { configInternal | maxWeight = maxWeight }


{-| Set the render radius of each point in the heatmap (25 by default).

    myConfig
        |> withRadius 50

The points in the data get clustered relative to this value to improve render performance.
-}
withRadius : Float -> Config data -> Config data
withRadius radius (Config configInternal) =
    Config
        { configInternal | radius = radius }


{-| Set the blur factor of the heatmap (15 by default).

    myConfig
        |> withBlur 50
-}
withBlur : Float -> Config data -> Config data
withBlur blur (Config configInternal) =
    Config
        { configInternal | blur = blur }


{-| Add a suffix for `id` attributes in the generated Svg.

    myConfig
        |> withIdSuffix "clickTargets42"

The generated Svg depends on references between elements via their `id`.
An individual suffix makes sure that multiple heatmaps don't interfere.
-}
withIdSuffix : String -> Config data -> Config data
withIdSuffix idSuffix (Config configInternal) =
    Config
        { configInternal | idSuffix = Just idSuffix }



-- VIEW


{-| Take a `Config` and a `List` of `data` and turn it into a Svg based heatmap.

    view : Model -> Svg msg
    view model =
        Heatmap.view myConfig model.myData

**Note:** The `view` function generates a `Svg.g` element as its root. So you are responsible to embed in a `Svg.svg` element to actually render a heatmap. This makes it easy to define e.g. styling and events for the containing Svg.

The generated Svg looks like this.

    g []
        [ defs []
            [ {- helper elements and filter definition -} ]
        , g [ filter "url(#heatmapFilter)" ]
            [ {- list of clustered points -} ]
        ]
-}
view : Config data -> List data -> Svg msg
view config data =
    Svg.g []
        [ viewDefinitions config
        , viewData config data
        ]


{-| Render the data list as a group of blurred circles.
-}
viewData : Config data -> List data -> Svg msg
viewData ((Config { toPoint }) as config) data =
    Svg.g
        [ Svg.Attributes.filter (linkToIdentifier config filterName) ]
        (data
            |> List.map toPoint
            |> cluster config
            |> List.map (viewPoint config)
        )


{-| Render a single point by referencing a circle.
-}
viewPoint : Config data -> Point -> Svg msg
viewPoint ((Config { maxWeight }) as config) { x, y, weight } =
    Svg.use
        [ Svg.Attributes.xlinkHref (referenceIdentifier config pointName)
        , Svg.Attributes.x (toString x)
        , Svg.Attributes.y (toString y)
        , Svg.Attributes.fillOpacity (toString <| weight / maxWeight)
        ]
        []


{-| Render filter and helper definitions.
-}
viewDefinitions : Config data -> Svg msg
viewDefinitions ((Config { radius }) as config) =
    Svg.defs []
        [ -- Each point gets filled with a gradient.
          Svg.radialGradient
            [ Svg.Attributes.id (identifier config pointGradientName) ]
            [ Svg.stop
                [ Svg.Attributes.offset "0%"
                , Svg.Attributes.stopColor "black"
                , Svg.Attributes.stopOpacity "1"
                ]
                []
            , Svg.stop
                [ Svg.Attributes.offset "100%"
                , Svg.Attributes.stopColor "black"
                , Svg.Attributes.stopOpacity "0"
                ]
                []
            ]

        -- A stamp for each rendered point.
        , Svg.circle
            [ Svg.Attributes.id (identifier config pointName)
            , Svg.Attributes.r (toString radius)
            , Svg.Attributes.fill (linkToIdentifier config pointGradientName)
            ]
            []
        , viewFilter config
        ]


{-| Renders the heatmap filter definition.

The group containing the points of the heatmap use this filter.
The general idea is
- Blur all points. Points are black only at this stage with a radial gradient to 0 opacity in the outer direction.
- Fill everything with a fully white overlay, but with a very low opacity.
- Blend the blurred circles and the fill together to create a greyscale image.
- Apply a `feComponentTransfer` that turns the different shades of grey into a colors at a position in the gradient relative to the blackness of the grey. It also adjusts the opacity slightly to remove the fully white background where there are no points.
-}
viewFilter : Config data -> Svg msg
viewFilter ((Config { blur, gradient }) as config) =
    Svg.filter
        [ Svg.Attributes.id (identifier config filterName)
        , Svg.Attributes.width "120%"
        , Svg.Attributes.height "120%"
        , Svg.Attributes.x "-10%"
        , Svg.Attributes.y "-10%"
        , Svg.Attributes.filterUnits "userSpaceOnUse"
        ]
        [ Svg.feGaussianBlur
            [ Svg.Attributes.in_ "SourceGraphic"
            , Svg.Attributes.stdDeviation (toString blur)
            , Svg.Attributes.result "blurred"
            ]
            []
        , Svg.feFlood
            [ Svg.Attributes.floodColor "white"
            , Svg.Attributes.floodOpacity "0.1"
            , Svg.Attributes.result "flooded"
            ]
            []
        , Svg.feBlend
            [ Svg.Attributes.in_ "flooded"
            , Svg.Attributes.in2 "blurred"
            , Svg.Attributes.mode "multiply"
            , Svg.Attributes.result "toTransfer"
            ]
            []
        , viewGradientComponentTransferFilter gradient
        ]


{-| Create a `feComponentTransfer` element that turns a greyscale heatmap into a colored one for a given gradient.
-}
viewGradientComponentTransferFilter : Gradient -> Svg msg
viewGradientComponentTransferFilter gradient =
    let
        componentTransferPalette =
            Color.Gradient.linearGradientFromStops Color.Interpolate.RGB gradient 128
                |> List.reverse
                |> List.map Color.toRgb
                |> List.map
                    (\{ red, green, blue } ->
                        { red = toFloat red / 256 |> clamp 0 1
                        , green = toFloat green / 256 |> clamp 0 1
                        , blue = toFloat blue / 256 |> clamp 0 1
                        }
                    )

        componentTransferTableValues color =
            componentTransferPalette
                |> List.map (color >> toString)
                |> String.join " "
    in
        Svg.feComponentTransfer
            [ Svg.Attributes.in_ "toTransfer" ]
            [ Svg.feFuncR
                [ Svg.Attributes.type_ "table"
                , Svg.Attributes.tableValues
                    (componentTransferTableValues .red)
                ]
                []
            , Svg.feFuncG
                [ Svg.Attributes.type_ "table"
                , Svg.Attributes.tableValues
                    (componentTransferTableValues .green)
                ]
                []
            , Svg.feFuncB
                [ Svg.Attributes.type_ "table"
                , Svg.Attributes.tableValues
                    (componentTransferTableValues .blue)
                ]
                []

            -- The opacity of the white flood fill is at `0.1`.
            -- This shifts the opacity to not render the white-only parts of the greyscale heatmap version.
            , Svg.feFuncA
                [ Svg.Attributes.type_ "table"
                , Svg.Attributes.tableValues "0 0 0.5 0.6 0.7 0.8 0.9 1"
                ]
                []
            ]


filterName : String
filterName =
    "Filter"


pointName : String
pointName =
    "Point"


pointGradientName : String
pointGradientName =
    "PointGradient"


identifier : Config data -> String -> String
identifier (Config { idSuffix }) name =
    let
        suffix =
            idSuffix
                |> Maybe.map ((++) "_")
                |> Maybe.withDefault ""
    in
        "heatmap" ++ name ++ suffix


referenceIdentifier : Config data -> String -> String
referenceIdentifier config name =
    "#" ++ identifier config name


linkToIdentifier : Config data -> String -> String
linkToIdentifier config name =
    "url(" ++ referenceIdentifier config name ++ ")"



-- CLUSTERING


type alias Grid =
    Dict ( Int, Int ) Point


cluster : Config data -> List Point -> List Point
cluster config points =
    points
        |> clusterHelp config Dict.empty
        |> Dict.values


clusterHelp : Config data -> Grid -> List Point -> Grid
clusterHelp ((Config { radius }) as config) grid points =
    case points of
        ({ x, y, weight } as point) :: rest ->
            let
                cellSize =
                    radius / 2

                xCell =
                    floor (x / cellSize)

                yCell =
                    floor (y / cellSize)

                addPoint maybeExistingPoint =
                    case maybeExistingPoint of
                        Just existingPoint ->
                            Just (mergePoints existingPoint point)

                        Nothing ->
                            Just point

                newGrid =
                    Dict.update ( xCell, yCell )
                        addPoint
                        grid
            in
                clusterHelp config newGrid rest

        [] ->
            grid


mergePoints : Point -> Point -> Point
mergePoints p1 p2 =
    { x =
        (p1.x * p1.weight + p2.x * p2.weight)
            / (p1.weight + p2.weight)
    , y =
        (p1.y * p1.weight + p2.y * p2.weight)
            / (p1.weight + p2.weight)
    , weight =
        p1.weight + p2.weight
    }
