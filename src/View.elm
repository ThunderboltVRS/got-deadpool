module View exposing (view)

import DeathChart exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick)
import Html.Events.Extra exposing (..)
import Json.Decode as Json
import Types exposing (..)
import Util exposing (..)


view : Model -> Html Msg
view model =
    div
        [ style "height" "100%" ]
        [ tabs model
        , tabContent model
        ]


tabContent : Model -> Html Msg
tabContent model =
    div
        [ class "section main-background" ]
        [ case model.selectedTab of
            TabMyPredictions ->
                div
                    [ class "columns is-multiline is-centered is-vcentered" ]
                    (List.map (characterDetails model) model.characters)

            TabMyStats ->
                statsView model

            TabInfo ->
                div [ class "columns is-multiline is-centered is-vcentered" ] [ infoView model ]
        ]


tabs : Model -> Html Msg
tabs model =
    div [ class "tabs is-toggle is-fullwidth is-medium is-centered" ]
        [ ul []
            [ li [ class (tabClass model TabInfo) ]
                [ a [ onClick (TabSelected TabInfo) ]
                    [ span []
                        [ text "Home" ]
                    ]
                ]
            , li [ class (tabClass model TabMyPredictions) ]
                [ a [ onClick (TabSelected TabMyPredictions) ]
                    [ span []
                        [ text "Predictions" ]
                    ]
                ]
            , li [ class (tabClass model TabMyStats) ]
                [ a [ onClick (TabSelected TabMyStats) ]
                    [ span []
                        [ text "Scores" ]
                    ]
                ]
            ]
        ]


statsView : Model -> Html Msg
statsView model =
    div []
        [ div [ class "columns is-multiline is-centered is-vcentered stat-row" ]
            [ div [ class "column" ]
                [ div [ class "box" ]
                    [ h1 [ class "title" ] [ text "Scores" ]
                    , userScoresTable model
                    ]
                ]
            ]

        -- , div
        --     [ class "columns is-multiline is-centered is-vcentered stat-row" ]
        --     [ yourScoreCard model
        --     , diedSoFarCard model
        --     ]
        , div
            [ class "columns is-multiline is-centered is-vcentered stat-row" ]
            [ predictionDeathChart model
            , actualDeathChart model
            ]
        ]


userScoresTable : Model -> Html Msg
userScoresTable model =
    table [ class "table is-striped is-narrow is-hoverable is-fullwidth" ]
        [ thead []
            [ tr []
                [ th [ style "width" "50%" ]
                    [ text "Name" ]
                , th [ style "width" "50%" ]
                    [ text "Score" ]
                ]
            ]
        , tbody []
            (model.userScores
                |> List.map
                    (\userScore ->
                        tr [ classList [ ( "is-selected", model.uid == userScore.uid ) ] ]
                            [ td [ style "width" "50%" ] [ Html.text userScore.displayName ]
                            , td [ style "width" "50%" ] [ Html.text (String.fromInt userScore.score) ]
                            ]
                    )
            )
        ]


tabClass : Model -> TabType -> String
tabClass model tabType =
    if model.selectedTab == tabType then
        "is-active"

    else
        ""


characterDetails : Model -> Character -> Html Msg
characterDetails model character =
    let
        mPrediction =
            findPrediction model character
    in
    case mPrediction of
        Just prediction ->
            characterCard model character prediction

        Nothing ->
            div [] []


predictionDeathChart : Model -> Html Msg
predictionDeathChart model =
    div [ class "column is-half" ]
        [ div [ class "box" ]
            [ h1 [ class "title" ]
                [ text "Deaths Per Episode (You Predicted)" ]
            , predictedDeathChart model
            ]
        ]


yourScoreCard : Model -> Html Msg
yourScoreCard model =
    div [ class "column is-narrow" ]
        [ div [ class "box" ]
            [ h1 [ class "title" ]
                [ text "Your Score" ]
            , h2 [ class "title is-1" ]
                [ text "0" ]
            ]
        ]


diedSoFarCard : Model -> Html Msg
diedSoFarCard model =
    div [ class "column is-narrow" ]
        [ div [ class "box" ]
            [ h1 [ class "title" ]
                [ text "Death Counter" ]
            , h2 [ class "title is-1" ]
                [ text "0" ]
            ]
        ]


actualDeathChart : Model -> Html Msg
actualDeathChart model =
    div [ class "column is-half" ]
        [ div [ class "box" ]
            [ h1 [ class "title" ]
                [ text "Deaths Per Episode (Actual)" ]
            , aDeathChart model
            ]
        ]


infoView : Model -> Html Msg
infoView model =
    div []
        [ div [ class "column is-full" ]
            [ div [ class "box" ]
                [ h1 [ class "title" ]
                    [ text "Winter is coming..." ]
                , p [] [ text "Game of Thrones Deadpool. Predict the fate of all the major characters for the final season." ]
                ]
            ]
        , div [ class "column is-full" ]
            [ div [ class "box" ]
                [ h1 [ class "title" ]
                    [ text "How It Works" ]
                , p []
                    [ ol [ style "padding" "1.25rem" ]
                        [ li []
                            [ text "Use the predictions tab to make your predictions per character. Changes are immediately saved." ]
                        , li []
                            [ text "At some point close to the first episode, you will no longer be able to make predictions." ]
                        , li []
                            [ text "On a Monday after each episode is aired, the status of the character will be input." ]
                        , li []
                            [ text "Scores will be calculated:"
                            , ul []
                                [ li []
                                    [ text "A point for correctly guessing if they live or die."
                                    ]
                                , li []
                                    [ text "A bonus point for guessing the correct episode of death."
                                    ]
                                ]
                            ]
                        , li []
                            [ text "Everyone's score is displayed in a ranked table on the scores tab."
                            ]
                        ]
                    ]
                ]
            ]
        , div [ class "column is-full" ]
            [ div [ class "box" ]
                [ h1 [ class "title" ]
                    [ text "The Rules" ]
                , p []
                    [ ol [ style "padding" "1.25rem" ]
                        [ li []
                            [ text "Resuurections will not revert a character's status of 'Dies'" ]
                        , li []
                            [ text "Conversion to a White Walker will count as a death" ]
                        , li []
                            [ text "Any presumed death offscreen will be counted as a death" ]
                        , li []
                            [ text "A death between episodes will count as a death on the latter episode" ]
                        , li []
                            [ text "My word is final." ]
                        ]
                    ]
                ]
            ]
        , div [ class "column is-full" ]
            [ div [ class "box" ]
                [ h1 [ class "title" ]
                    [ text "Author" ]
                , p []
                    [ div []
                        [ text "Created by Gary Stanton. Written in Elm, using Firestore database to store predictions and cloud functions to compute scores. Full source code on Github. "
                        ]
                    , br [] []
                    , a [ class "button is-medium is-link", href "https://github.com/ThunderboltVRS/got-deadpool" ]
                        [ span [ class "icon" ]
                            [ i [ class "fab fa-github" ]
                                []
                            ]
                        , span []
                            [ text "GitHub" ]
                        ]
                    , br [] []
                    , br [] []
                    , div [] [ text "Background image by by mauRÍCIO santos: ", a [ href "https://unsplash.com/photos/N1gFsYf9AI0" ] [ text "link" ] ]
                    , div [] [ text "Title image by Xeworlebi: ", a [ href "https://de.wikipedia.org/wiki/Datei:Game_of_Thrones_2011_logo.svg" ] [ text "link" ] ]
                    ]
                ]
            ]
        ]


characterCard : Model -> Character -> Prediction -> Html Msg
characterCard model character prediction =
    div [ class "column is-narrow" ]
        [ div [ class "card" ]
            [ div [ class "card-content" ]
                [ div [ class "media" ]
                    [ figure [ class "media-left" ]
                        [ img [ class "image character-pic", src character.pictureUrl ]
                            []
                        ]
                    , div [ class "media-content" ]
                        [ p [ class "title is-4" ]
                            [ text character.name ]
                        , aliveStatusSelection model character prediction
                        , br [] []
                        , br [] []
                        , if prediction.aliveStatus == Dies then
                            episodeSelection model character prediction

                          else
                            div [] []
                        ]
                    , div [ class "media-right" ]
                        [ span [ class "icon is-large" ]
                            [ i [ class (characterIconClass character) ]
                                []
                            ]
                        ]
                    ]
                ]
            ]
        ]


characterIconClass : Character -> String
characterIconClass character =
    case character.aliveStatus of
        Lives ->
            if character.locked && not character.confirmed then
                "fas fa-2x fa-lock"

            else
                ""

        Dies ->
            "fas fa-2x fa-skull-crossbones"


aliveStatusSelection : Model -> Character -> Prediction -> Html Msg
aliveStatusSelection model character prediction =
    div [ class "select is-medium" ]
        [ select
            [ on "change" (Json.map (UpdateStatePrediction character) Html.Events.targetValue)
            , disabled (aliveDropDownDisabled character prediction)
            ]
            [ aliveStatusOption Lives prediction
            , aliveStatusOption Dies prediction
            ]
        ]


aliveStatusOption : AliveStatus -> Prediction -> Html Msg
aliveStatusOption status prediction =
    option
        [ Html.Attributes.selected (statusPredictionMatches status prediction)
        , Html.Attributes.value (aliveStatusToString status)
        ]
        [ text (aliveStatusToString status) ]


aliveDropDownDisabled : Character -> Prediction -> Bool
aliveDropDownDisabled character prediction =
    character.locked || character.confirmed


episodeSelection : Model -> Character -> Prediction -> Html Msg
episodeSelection model character prediction =
    div [ class "select is-medium" ]
        [ select
            [ on "change" (Json.map (UpdateEpisodePrediction character) Html.Events.targetValue)
            , disabled (episodeDropDownDisabled character prediction)
            ]
            (episodeSelectionOptions model character prediction)
        ]


episodeSelectionOptions : Model -> Character -> Prediction -> List (Html Msg)
episodeSelectionOptions model character prediction =
    [ episodeSelectionOption One prediction
    , episodeSelectionOption Two prediction
    , episodeSelectionOption Three prediction
    , episodeSelectionOption Four prediction
    , episodeSelectionOption Five prediction
    , episodeSelectionOption Six prediction
    ]


episodeDropDownDisabled : Character -> Prediction -> Bool
episodeDropDownDisabled character prediction =
    character.locked || character.confirmed


episodeSelectionOption : Episode -> Prediction -> Html Msg
episodeSelectionOption episode prediction =
    option
        [ Html.Attributes.selected (episodePredictionMatches episode prediction)
        , Html.Attributes.value (episodeToString episode)
        , disabled (prediction.aliveStatus == Lives && not (episode == Six))
        ]
        [ text (episodeToString episode) ]


statusPredictionMatches : AliveStatus -> Prediction -> Bool
statusPredictionMatches aliveStatus prediction =
    aliveStatus == prediction.aliveStatus


episodePredictionMatches : Episode -> Prediction -> Bool
episodePredictionMatches episode prediction =
    episode == prediction.episode


findPrediction : Model -> Character -> Maybe Prediction
findPrediction model character =
    List.filter (\p -> p.characterId == character.id) model.predictions
        |> List.head


findPredictionScore : Model -> Character -> Maybe PredictionScore
findPredictionScore model character =
    List.filter (\p -> p.characterId == character.id) model.predictionScores
        |> List.head


scoreNumber : Maybe PredictionScore -> Int
scoreNumber mPredictionScore =
    case mPredictionScore of
        Just predictionScore ->
            predictionScore.score

        Nothing ->
            0
