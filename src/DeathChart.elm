module DeathChart exposing (aDeathChart, predictedDeathChart)

import Axis
import Dict exposing (..)
import OrderedDict
import Scale exposing (BandConfig, BandScale, ContinuousScale, defaultBandConfig)
import Time
import TypedSvg exposing (g, rect, style, svg, text_)
import TypedSvg.Attributes exposing (class, textAnchor, transform, viewBox)
import TypedSvg.Attributes.InPx exposing (height, width, x, y)
import TypedSvg.Core exposing (Svg, text)
import TypedSvg.Types exposing (AnchorAlignment(..), Transform(..))
import Types exposing (..)
import Util exposing (..)


w : Float
w =
    700


h : Float
h =
    300


padding : Float
padding =
    30


xScale : List ( String, Float ) -> BandScale String
xScale model =
    List.map Tuple.first model
        |> Scale.band { defaultBandConfig | paddingInner = 0.1, paddingOuter = 0.2 } ( 0, w - 2 * padding )


yScale : ContinuousScale Float
yScale =
    Scale.linear ( h - 2 * padding, 0 ) ( 0, 8 )


xAxis : List ( String, Float ) -> Svg msg
xAxis model =
    Axis.bottom [] (Scale.toRenderable identity (xScale model))


yAxis : Svg msg
yAxis =
    Axis.left [ Axis.tickCount 8 ] yScale


column : BandScale String -> ( String, Float ) -> Svg msg
column scale ( episodeString, value ) =
    g [ class [ "column" ] ]
        [ rect
            [ x <| Scale.convert scale episodeString
            , y <| Scale.convert yScale value
            , width <| Scale.bandwidth scale
            , height <| h - Scale.convert yScale value - 2 * padding
            ]
            []
        , text_
            [ x <| Scale.convert (Scale.toRenderable identity scale) episodeString
            , y <| Scale.convert yScale value - 5
            , textAnchor AnchorMiddle
            ]
            [ text <| String.fromFloat value ]
        ]


view : List ( String, Float ) -> Svg msg
view model =
    svg [ viewBox 0 0 w h ]
        [ style [] [ text """
            .column rect { fill: #2366d1; }
            g .column:hover text { display: inline; }
            rect:hover {fill: #209cee}
            g .column text { display: none; }
            
          """ ]
        , g [ transform [ Translate (padding - 1) (h - padding) ] ]
            [ xAxis model ]
        , g [ transform [ Translate (padding - 1) padding ] ]
            [ yAxis ]
        , g [ transform [ Translate padding padding ], class [ "series" ] ] <|
            List.map (column (xScale model)) model
        ]


groupAndCount : List String -> Dict String Int
groupAndCount tags =
    tags
        |> List.foldr
            (\tag carry ->
                Dict.update
                    tag
                    (\existingCount ->
                        case existingCount of
                            Just c ->
                                Just (c + 1)

                            Nothing ->
                                Just 1
                    )
                    carry
            )
            Dict.empty


predictedDeathChart : Model -> Svg Msg
predictedDeathChart model =
    model.predictions
        |> List.filter (\p -> p.aliveStatus == Dies)
        |> List.map (\p -> episodeToString p.episode)
        |> groupAndCount
        |> mergeOrdered
        |> OrderedDict.toList
        |> List.map (\g -> ( Tuple.first g, toFloat (Tuple.second g) ))
        |> view


aDeathChart : Model -> Svg Msg
aDeathChart model =
    model.characters
        |> List.filter (\p -> p.aliveStatus == Dies)
        |> List.map (\p -> episodeToString p.episode)
        |> groupAndCount
        |> mergeOrdered
        |> OrderedDict.toList
        |> List.map (\g -> ( Tuple.first g, toFloat (Tuple.second g) ))
        |> view


findValue : String -> Dict String Int -> Int
findValue key dictA =
    Maybe.withDefault 0 (Dict.get key dictA)


unionFlipped first second =
    Dict.union second first


baseDict =
    OrderedDict.fromList
        [ ( episodeToString One, 0 )
        , ( episodeToString Two, 0 )
        , ( episodeToString Three, 0 )
        , ( episodeToString Four, 0 )
        , ( episodeToString Five, 0 )
        , ( episodeToString Six, 0 )
        ]


mergeOrdered dictA =
    OrderedDict.map
        (\k v -> v + findValue k dictA)
        baseDict
