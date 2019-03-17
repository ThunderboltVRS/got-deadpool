port module Ports exposing (aliveDecoder, aliveStatusEncoder, characterDecoder, decodeCharacters, decodeCharactersAndCreateMsg, decodeUserData, decodeUserDataAndCreateMsg, decodeUserScores, decodeUserScoresAndCreateMsg, encodePrediction, encodeUserData, episdoeDecoder, episodeEncoder, loadCharacters, loadUserData, loadUserScores, logOut, predictionDecoder, saveUserData, userDataEncoder, userScoreDecoder)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (..)
import Types exposing (..)


port loadCharacters : (Decode.Value -> msg) -> Sub msg


port loadUserData : (Decode.Value -> msg) -> Sub msg


port loadUserScores : (Decode.Value -> msg) -> Sub msg


port saveUserData : Encode.Value -> Cmd a


port logOut : String -> Cmd a



-- LoadUserScores


decodeUserScoresAndCreateMsg : Decode.Value -> Msg
decodeUserScoresAndCreateMsg jsonValue =
    case decodeUserScores jsonValue of
        Ok userScores ->
            LoadUserScores userScores

        Err errorMessage ->
            -- let
            --     _ =
            --         Debug.log "Error in mapWorkerUpdated:" errorMessage
            -- in
            Error errorMessage


decodeUserScores : Decode.Value -> Result Decode.Error (List UserScore)
decodeUserScores =
    Decode.decodeValue
        (Decode.field "allScores" (Decode.list userScoreDecoder))


userScoreDecoder : Decoder UserScore
userScoreDecoder =
    Decode.succeed UserScore
        |> required "uid" Decode.string
        |> required "displayName" Decode.string
        |> required "score" Decode.int



-- Characters


decodeCharactersAndCreateMsg : Decode.Value -> Msg
decodeCharactersAndCreateMsg jsonValue =
    case decodeCharacters jsonValue of
        Ok characters ->
            LoadCharacters characters

        Err errorMessage ->
            -- let
            --     _ =
            --         Debug.log "Error in mapWorkerUpdated:" errorMessage
            -- in
            Error errorMessage


decodeCharacters : Decode.Value -> Result Decode.Error (List Character)
decodeCharacters =
    Decode.decodeValue
        (Decode.field "characters" (Decode.list characterDecoder))


characterDecoder : Decoder Character
characterDecoder =
    Decode.succeed Character
        |> required "id" Decode.string
        |> required "name" Decode.string
        |> required "aliveStatus" aliveDecoder
        |> required "episode" episdoeDecoder
        |> required "deathNotes" Decode.string
        |> required "confirmed" Decode.bool
        |> required "pictureUrl" Decode.string
        |> required "locked" Decode.bool



-- Predictions


decodeUserDataAndCreateMsg : Decode.Value -> Msg
decodeUserDataAndCreateMsg jsonValue =
    case decodeUserData jsonValue of
        Ok userData ->
            LoadUserData userData

        Err errorMessage ->
            -- let
            --     _ =
            --         Debug.log "Error in mapWorkerUpdated:" errorMessage
            -- in
            Error errorMessage


decodeUserData : Decode.Value -> Result Decode.Error UserData
decodeUserData =
    Decode.decodeValue userDataEncoder


userDataEncoder : Decoder UserData
userDataEncoder =
    Decode.succeed UserData
        |> required "uid" Decode.string
        |> required "predictions" (Decode.list predictionDecoder)
        |> required "displayName" Decode.string


predictionDecoder : Decoder Prediction
predictionDecoder =
    Decode.succeed Prediction
        |> required "characterId" Decode.string
        |> required "aliveStatus" aliveDecoder
        |> required "episode" episdoeDecoder


encodeUserData : String -> String -> List Prediction -> Encode.Value
encodeUserData uid displayName predictions =
    Encode.object
        [ ( "uid", Encode.string uid )
        , ( "predictions", Encode.list encodePrediction predictions )
        , ( "displayName", Encode.string displayName )
        ]


encodePrediction : Prediction -> Encode.Value
encodePrediction record =
    Encode.object
        [ ( "characterId", Encode.string <| record.characterId )
        , ( "aliveStatus", aliveStatusEncoder <| record.aliveStatus )
        , ( "episode", episodeEncoder <| record.episode )
        ]



-- Common


aliveStatusEncoder : AliveStatus -> Encode.Value
aliveStatusEncoder status =
    case status of
        Lives ->
            Encode.string "Lives"

        Dies ->
            Encode.string "Dies"


episodeEncoder : Episode -> Encode.Value
episodeEncoder episode =
    case episode of
        None ->
            Encode.string "None"

        One ->
            Encode.string "Episode One"

        Two ->
            Encode.string "Episode Two"

        Three ->
            Encode.string "Episode Three"

        Four ->
            Encode.string "Episode Four"

        Five ->
            Encode.string "Episode Five"

        Six ->
            Encode.string "Episode Six"


aliveDecoder : Decoder AliveStatus
aliveDecoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Lives" ->
                        Decode.succeed Lives

                    "Dies" ->
                        Decode.succeed Dies

                    other ->
                        Decode.fail <| "Unkown type: " ++ other
            )


episdoeDecoder : Decoder Episode
episdoeDecoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "None" ->
                        Decode.succeed None

                    "Episode One" ->
                        Decode.succeed One

                    "Episode Two" ->
                        Decode.succeed Two

                    "Episode Three" ->
                        Decode.succeed Three

                    "Episode Four" ->
                        Decode.succeed Four

                    "Episode Five" ->
                        Decode.succeed Five

                    "Episode Six" ->
                        Decode.succeed Six

                    other ->
                        Decode.fail <| "Unkown type: " ++ other
            )
