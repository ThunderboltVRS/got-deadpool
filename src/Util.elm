module Util exposing (aliveStatusToString, episodeToString, match, stringToEpisode, stringToState)

import Regex
import Tuple
import Types exposing (..)


aliveStatusToString : AliveStatus -> String
aliveStatusToString state =
    case state of
        Lives ->
            "Lives"

        Dies ->
            "Dies"


stringToState : String -> AliveStatus
stringToState stateString =
    case stateString of
        "Lives" ->
            Lives

        "Dies" ->
            Dies

        _ ->
            Lives


stringToEpisode : String -> Episode
stringToEpisode string =
    case string of
        "-" ->
            None

        "Episode One" ->
            One

        "Episode Two" ->
            Two

        "Episode Three" ->
            Three

        "Episode Four" ->
            Four

        "Episode Five" ->
            Five

        "Episode Six" ->
            Six

        _ ->
            None


episodeToString : Episode -> String
episodeToString episode =
    case episode of
        None ->
            "-"

        One ->
            "Episode One"

        Two ->
            "Episode Two"

        Three ->
            "Episode Three"

        Four ->
            "Episode Four"

        Five ->
            "Episode Five"

        Six ->
            "Episode Six"


match : String -> String -> Bool
match conatined inside =
    let
        regex =
            Maybe.withDefault Regex.never <| Regex.fromStringWith { caseInsensitive = True, multiline = False } conatined
    in
    Regex.contains regex inside
