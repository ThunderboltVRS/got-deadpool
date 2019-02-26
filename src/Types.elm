module Types exposing (AliveStatus(..), Character, Episode(..), Flags, Model, Msg(..), Prediction, PredictionScore, TabType(..), UserData, UserScore)

import Http
import Json.Decode as Decode exposing (Decoder)
import Time


type Msg
    = UpdateEpisodePrediction Character String
    | UpdateStatePrediction Character String
    | LoadCharacters (List Character)
    | LoadUserScores (List UserScore)
    | LoadUserData UserData
    | TabSelected TabType
    | Error Decode.Error


type AliveStatus
    = Lives
    | Dies


type Episode
    = None
    | One
    | Two
    | Three
    | Four
    | Five
    | Six


type TabType
    = TabMyPredictions
    | TabMyStats
    | TabInfo


type alias Model =
    { authToken : String
    , uid : String
    , displayName : String
    , predictions : List Prediction
    , characters : List Character
    , currentEpisode : Episode
    , predictionScores : List PredictionScore
    , selectedTab : TabType
    , userScores : List UserScore
    }


type alias Flags =
    { authToken : String
    , displayName : String
    , uid : String
    }


type alias Character =
    { id : String
    , name : String
    , aliveStatus : AliveStatus
    , episode : Episode
    , deathNotes : String
    , confirmed : Bool
    , pictureUrl : String
    , locked : Bool
    }


type alias Prediction =
    { characterId : String
    , aliveStatus : AliveStatus
    , episode : Episode
    }


type alias PredictionScore =
    { characterId : String
    , aliveStatusCorrect : Bool
    , episodeCorrect : Bool
    , score : Int
    }


type alias UserData =
    { uid : String
    , predictions : List Prediction
    , displayName : String
    }

type alias UserScore =
    { uid : String
    , displayName : String
    , score : Int
    }
