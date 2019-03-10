module States exposing (init, subscriptions)

import Ports exposing (..)
import Task
import Types exposing (..)


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags, Cmd.none )


initialModel : Flags -> Model
initialModel flags =
    { authToken = flags.authToken
    , uid = flags.uid
    , displayName = flags.displayName
    , predictions = []
    , characters = []
    , currentEpisode = None
    , predictionScores = []
    , selectedTab = TabInfo
    , userScores = []
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ loadCharacters decodeCharactersAndCreateMsg, loadUserData decodeUserDataAndCreateMsg, loadUserScores decodeUserScoresAndCreateMsg ]
