module Heatmap.Gradient
    exposing
        ( Gradient
        , blackAquaWhite
        , blueRed
        , colorSpectrum
        , deepSea
        , incandescent
        , heatedMetal
        , steppedColors
        , sunrise
        , visibleSpectrum
        )

{-| Gradient definitions for heatmaps.

## Definition

@docs Gradient

## Useful gradients

As seen in <https://msdn.microsoft.com/en-us/library/mt712854.aspx>

@docs blackAquaWhite, blueRed, colorSpectrum, deepSea, heatedMetal, incandescent, steppedColors, sunrise, visibleSpectrum
-}

import Color
import Color.Gradient


{-| Re-exposed [`Gradient`](http://package.elm-lang.org/packages/eskimoblood/elm-color-extra/5.0.0/Color-Gradient#Gradient) definition from the [elm-color-extra](http://package.elm-lang.org/packages/eskimoblood/elm-color-extra/5.0.0/) package.

A `Gradient` is a list of [Color](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Color#Color) and stop values. The stop value must be between `0` and `1`.

    sunrise =
        [ ( 0, Color.rgb 255 0 0 )
        , ( 0.66, Color.rgb 255 255 0 )
        , ( 1, Color.rgb 255 255 255 )
        ]

The gradient is used to colorize the intensity of the values in the heatmap, from lowest to highest.
-}
type alias Gradient =
    Color.Gradient.Gradient


{-| <div style="background: linear-gradient(to right, rgb(0,0,0), rgb(0,255,255) 60%, rgb(255,255,255))">&nbsp;</div>
-}
blackAquaWhite : Gradient
blackAquaWhite =
    [ ( 0, Color.rgb 0 0 0 )
    , ( 0.6, Color.rgb 0 255 255 )
    , ( 1, Color.rgb 255 255 255 )
    ]


{-| <div style="background: linear-gradient(to right, rgb(0,0,255), rgb(255,0,0))">&nbsp;</div>
-}
blueRed : Gradient
blueRed =
    [ ( 0, Color.rgb 0 0 255 )
    , ( 1, Color.rgb 255 0 0 )
    ]


{-| <div style="background: linear-gradient(to right, rgb(0,0,128), rgb(0,0,255) 25%, rgb(0,128,0) 50%, rgb(255,255,0) 75%, rgb(255,0,0)">&nbsp;</div>
-}
colorSpectrum : Gradient
colorSpectrum =
    [ ( 0, Color.rgb 0 0 128 )
    , ( 0.25, Color.rgb 0 0 255 )
    , ( 0.5, Color.rgb 0 128 0 )
    , ( 0.75, Color.rgb 255 255 0 )
    , ( 1, Color.rgb 255 0 0 )
    ]


{-| <div style="background: linear-gradient(to right, rgb(0,0,0), rgb(24,53,103) 60%, rgb(46,100,158) 75%, rgb(23,173,201) 90%, rgb(0,250,250)">&nbsp;</div>
-}
deepSea : Gradient
deepSea =
    [ ( 0, Color.rgb 0 0 0 )
    , ( 0.6, Color.rgb 24 53 103 )
    , ( 0.75, Color.rgb 46 100 158 )
    , ( 0.9, Color.rgb 23 173 201 )
    , ( 1, Color.rgb 0 250 250 )
    ]


{-| <div style="background: linear-gradient(to right, rgb(0,0,0), rgb(0,0,255) 33%, rgb(139,0,0) 66%, rgb(255,255,255)">&nbsp;</div>
-}
incandescent : Gradient
incandescent =
    [ ( 0, Color.rgb 0 0 0 )
    , ( 0.33, Color.rgb 0 0 255 )
    , ( 0.66, Color.rgb 139 0 0 )
    , ( 1, Color.rgb 255 255 255 )
    ]


{-| <div style="background: linear-gradient(to right, rgb(0,0,0), rgb(128,0,128) 40%, rgb(255,0,0) 60%, rgb(255,255,0) 80%, rgb(255,255,255)">&nbsp;</div>
-}
heatedMetal : Gradient
heatedMetal =
    [ ( 0, Color.rgb 0 0 0 )
    , ( 0.4, Color.rgb 128 0 128 )
    , ( 0.6, Color.rgb 255 0 0 )
    , ( 0.8, Color.rgb 255 255 0 )
    , ( 1, Color.rgb 255 255 255 )
    ]


{-| <div style="background: linear-gradient(to right, rgb(0,0,128), rgb(0,0,128) 25%, rgb(0,128,0) 26%, rgb(0,128,0) 50%, rgb(255,255,0) 51%, rgb(255,255,0) 75%, rgb(255,0,0) 76%, rgb(255,0,0)">&nbsp;</div>
-}
steppedColors : Gradient
steppedColors =
    [ ( 0, Color.rgb 0 0 128 )
    , ( 0.25, Color.rgb 0 0 128 )
    , ( 0.26, Color.rgb 0 128 0 )
    , ( 0.5, Color.rgb 0 128 0 )
    , ( 0.51, Color.rgb 255 255 0 )
    , ( 0.75, Color.rgb 255 255 0 )
    , ( 0.76, Color.rgb 255 0 0 )
    , ( 1, Color.rgb 255 0 0 )
    ]


{-| <div style="background: linear-gradient(to right, rgb(255,0,0), rgb(255,255,0) 66%, rgb(255,255,255)">&nbsp;</div>
-}
sunrise : Gradient
sunrise =
    [ ( 0, Color.rgb 255 0 0 )
    , ( 0.66, Color.rgb 255 255 0 )
    , ( 1, Color.rgb 255 255 255 )
    ]


{-| <div style="background: linear-gradient(to right, rgb(255,0,255), rgb(0,0,255) 25%, rgb(0,255,0) 50%, rgb(255,255,0) 75%, rgb(255,0,0)">&nbsp;</div>
-}
visibleSpectrum : Gradient
visibleSpectrum =
    [ ( 0, Color.rgb 255 0 255 )
    , ( 0.25, Color.rgb 0 0 255 )
    , ( 0.5, Color.rgb 0 255 0 )
    , ( 0.75, Color.rgb 255 255 0 )
    , ( 1, Color.rgb 255 0 0 )
    ]
