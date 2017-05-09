# Elm Heatmap

Svg based heatmaps in Elm.

The general idea is based on [simpleheat](https://github.com/mourner/simpleheat), which uses a `canvas` implementation.

The API is inspired by [evancz/elm-sortable-table](http://package.elm-lang.org/packages/evancz/elm-sortable-table/1.0.1) and [ohanhi/autoexpand](http://package.elm-lang.org/packages/ohanhi/autoexpand/2.0.0/), so do not put your `Heatmap.Config` into your `Model.

**Warning:** This is really not the fastest heatmap implementation, mainly because it's rendered in Svg. So it should probably not be used when the heatmap data or config changes a lot on user interaction and when render performance is critical.

Have a look at the `/examples/` to get a feeling how heatmaps look, perform and work.