module Update exposing (update)

import Date
import Maybe.Extra exposing (..)
import Ports exposing (encodeUserData, logOut, requestOtherUserData, saveUserData)
import Types exposing (..)
import Util exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateEpisodePrediction character episodeName ->
            let
                updatedModel =
                    updateEpisodePredictions model character (stringToEpisode episodeName) |> calculateScores
            in
            ( updatedModel, saveUserData (encodeUserData model.uid model.displayName updatedModel.predictions) )

        UpdateStatePrediction character stateName ->
            let
                updatedModel =
                    updatePredictionStates model character (stringToState stateName) |> calculateScores
            in
            ( updatedModel, saveUserData (encodeUserData model.uid model.displayName updatedModel.predictions) )

        LoadCharacters characters ->
            ( { model
                | characters = characters
                , predictions =
                    if List.isEmpty model.predictions then
                        defaultPredictions characters

                    else
                        model.predictions
              }
                |> calculateScores
            , Cmd.none
            )

        LoadUserData userData ->
            ( { model | predictions = userData.predictions } |> calculateScores
            , Cmd.none
            )

        LoadUserScores scores ->
            ( { model | userScores = List.reverse (List.sortBy .score scores) }, Cmd.none )

        TabSelected tab ->
            ( { model | selectedTab = tab }
            , Cmd.none
            )

        Error str ->
            ( model, Cmd.none )

        SearchUsers str ->
            ( { model | userSearchText = str }, Cmd.none )

        LogOut str ->
            ( model, logOut str )

        RequestOtherUserData str ->
            ( model, requestOtherUserData str )

        LoadOtherUserData userData ->
            ( { model | otherUserData = Just userData }, Cmd.none )

        ClearOtherUserData ->
            ( { model | otherUserData = Nothing }, Cmd.none )


updateEpisodePredictions : Model -> Character -> Episode -> Model
updateEpisodePredictions model character episode =
    { model | predictions = List.map (\pr -> updateEpisode model episode pr character) model.predictions }


updateEpisode : Model -> Episode -> Prediction -> Character -> Prediction
updateEpisode model episode prediction character =
    if prediction.characterId == character.id then
        { prediction | episode = episode }

    else
        prediction


updatePredictionStates : Model -> Character -> AliveStatus -> Model
updatePredictionStates model character aliveStatus =
    { model | predictions = List.map (\pr -> updatePredictionState model aliveStatus pr character) model.predictions }


updatePredictionState : Model -> AliveStatus -> Prediction -> Character -> Prediction
updatePredictionState model aliveStatus prediction character =
    if prediction.characterId == character.id then
        { prediction | aliveStatus = aliveStatus } |> resetEpisode

    else
        prediction


resetEpisode : Prediction -> Prediction
resetEpisode prediction =
    { prediction | episode = Six }


defaultPredictions : List Character -> List Prediction
defaultPredictions characters =
    List.map (\a -> newPrediction a) characters


newPrediction : Character -> Prediction
newPrediction character =
    { characterId = character.id
    , aliveStatus = Lives
    , episode = Six
    }


calculateScores : Model -> Model
calculateScores model =
    { model
        | predictionScores =
            List.map (\p -> calculateScore model p) model.predictions
                |> Maybe.Extra.values
    }


calculateScore : Model -> Prediction -> Maybe PredictionScore
calculateScore model prediction =
    let
        mCharacter =
            findCharacter model prediction
    in
    case mCharacter of
        Just character ->
            Just
                { characterId = character.id
                , aliveStatusCorrect = aliveStatusIsCorrect prediction character
                , episodeCorrect = episodeIsCorrect prediction character
                , score = scoreValue prediction character
                }

        Nothing ->
            Nothing


findCharacter : Model -> Prediction -> Maybe Character
findCharacter model prediction =
    List.filter (\p -> p.id == prediction.characterId) model.characters
        |> List.head


episodeIsCorrect : Prediction -> Character -> Bool
episodeIsCorrect prediction character =
    prediction.episode == character.episode


aliveStatusIsCorrect : Prediction -> Character -> Bool
aliveStatusIsCorrect prediction character =
    prediction.aliveStatus == character.aliveStatus


scoreValue : Prediction -> Character -> Int
scoreValue prediction character =
    let
        episodeScore =
            if episodeIsCorrect prediction character then
                1

            else
                0

        statusScore =
            if aliveStatusIsCorrect prediction character then
                1

            else
                0
    in
    episodeScore + statusScore
