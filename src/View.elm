module View exposing (view)

import DeathChart exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick)
import Html.Events.Extra exposing (..)
import Json.Decode as Json
import List.Extra
import Types exposing (..)
import Util exposing (..)


view : Model -> Html Msg
view model =
    div
        [ style "height" "100%" ]
        [ div [ class "navbar is-fixed-top" ] [ tabs model ]
        , tabContent model
        ]


tabContent : Model -> Html Msg
tabContent model =
    div
        [ class "section main-background" ]
        [ case model.selectedTab of
            TabMyPredictions ->
                characterTab model

            TabMyStats ->
                statsView model

            TabInfo ->
                infoView model
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
    div [ class "container" ]
        [ div [ class "columns is-multiline is-centered is-vcentered stat-row" ]
            [ div [ class "column is-two-thirds" ]
                [ div [ class "box" ]
                    [ h1 [ class "title" ] [ text "Scores" ]
                    , userSearch model
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
        , modal model
        ]


userSearch : Model -> Html Msg
userSearch model =
    div [ class "field is-horizontal has-addons" ]
        [ div [ class "control has-icons-left is-expanded" ]
            [ input [ class "input is-medium is-rounded", placeholder "Search Users", type_ "search", Html.Events.onInput SearchUsers ]
                []
            , span [ class "icon is-medium is-left" ]
                [ i [ class "fas fa-search" ]
                    []
                ]
            ]
        ]


userScoresTable : Model -> Html Msg
userScoresTable model =
    table [ class "table is-striped is-narrow is-hoverable is-fullwidth" ]
        [ thead []
            [ tr []
                [ th [ style "width" "50%" ]
                    [ text "Name" ]
                , th [ style "width" "25%" ]
                    [ text "Score" ]
                , th [ style "width" "25%" ]
                    [ text "Predictions" ]
                ]
            ]
        , tbody []
            (filteredUsers model
                |> List.map
                    (\userScore ->
                        tr [ classList [ ( "is-selected", model.uid == userScore.uid ) ] ]
                            [ td [ style "width" "50%" ] [ Html.text userScore.displayName ]
                            , td [ style "width" "25%" ] [ Html.text (String.fromInt userScore.score) ]
                            , td [ style "width" "25%" ]
                                [ if not (userScore.uid == model.uid) then
                                    a [ class "button is-link is-outlined", onClick (RequestOtherUserData userScore.uid) ]
                                        [ span []
                                            [ text "View" ]
                                        , span [ class "icon" ]
                                            [ i [ class "fas fa-caret-square-right" ]
                                                []
                                            ]
                                        ]

                                  else
                                    div [] []
                                ]
                            ]
                    )
            )
        ]


modal : Model -> Html Msg
modal model =
    case model.otherUserData of
        Just userData ->
            div
                [ onClick ClearOtherUserData
                , class "modal is-active"
                ]
                [ div [ class "modal-background" ]
                    []
                , div [ class "modal-content modal-container" ]
                    [ h1 [ class "title is-1 has-text-centered" ] [ text userData.displayName ]
                    , div [ class "container " ]
                        [ characterRow model userData.predictions model.characters ]
                    ]
                , button [ attribute "aria-label" "close", class "modal-close is-large" ]
                    []
                ]

        Nothing ->
            div [ class "modal" ] []


filteredUsers : Model -> List UserScore
filteredUsers model =
    if String.isEmpty model.userSearchText then
        model.userScores

    else
        List.filter (\u -> match model.userSearchText u.displayName) model.userScores


tabClass : Model -> TabType -> String
tabClass model tabType =
    if model.selectedTab == tabType then
        "is-active"

    else
        ""


characterTab : Model -> Html Msg
characterTab model =
    div [ class "container" ]
        [ characterRow model model.predictions model.characters ]


characterRow : Model -> List Prediction -> List Character -> Html Msg
characterRow model predictions characterSubList =
    div
        [ class "columns is-centered is-vcentered is-multiline" ]
        (List.map (characterDetails model predictions) characterSubList)


characterDetails : Model -> List Prediction -> Character -> Html Msg
characterDetails model predictions character =
    let
        mPrediction =
            findPrediction predictions character
    in
    case mPrediction of
        Just prediction ->
            characterCard model character prediction

        Nothing ->
            div [] []


predictionDeathChart : Model -> Html Msg
predictionDeathChart model =
    div [ class "column is-two-thirds" ]
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
    div [ class "column is-two-thirds" ]
        [ div [ class "box" ]
            [ h1 [ class "title" ]
                [ text "Deaths Per Episode (Actual)" ]
            , aDeathChart model
            ]
        ]


infoView : Model -> Html Msg
infoView model =
    div [ class "container" ]
        [ div [ class "columns is-multiline is-centered is-vcentered" ]
            [ div [ class "column is-two-thirds" ]
                [ div [ class "box" ]
                    [ h1 [ class "title is-1" ] [ text "Winter Has Come..." ]
                    , p []
                        [ text "You can now view other people's predictions."
                        ]
                    ]
                ]
            , div [ class "column is-two-thirds" ]
                [ div [ class "box" ]
                    [ h1 [ class "title" ]
                        [ text "How To Play" ]
                    , p []
                        [ ol []
                            [ li []
                                [ text "Use the predictions tab to make your predictions per character. Changes are immediately saved." ]
                            , li []
                                [ text "At some point close to the first episode, you will no longer be able to make predictions." ]
                            , li []
                                [ text "On a Monday after each episode is aired, the status of the character will updated." ]
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
            , div [ class "column is-two-thirds" ]
                [ div [ class "box" ]
                    [ h1 [ class "title" ]
                        [ text "The Rules" ]
                    , p []
                        [ ol []
                            [ li []
                                [ text "Resurections will not revert a character's status of 'Dies'" ]
                            , li []
                                [ text "Conversion to a White Walker will count as a death" ]
                            , li []
                                [ text "Any presumed death offscreen will be counted as a death" ]
                            , li []
                                [ text "A death between episodes will count as a death on the latter episode" ]
                            , li []
                                [ text "The Night King's death is the point which he ceases to be a Walker" ]
                            , li []
                                [ text "My word is final." ]
                            ]
                        ]
                    ]
                ]
            , div [ class "column is-two-thirds" ]
                [ div [ class "box" ]
                    [ h1 [ class "title" ]
                        [ text "Author" ]
                    , p []
                        [ p []
                            [ text "Created by Gary Stanton."
                            ]
                        , p []
                            [ text "Written in Elm, using Firestore database to store predictions and cloud functions to compute scores."
                            ]
                        , br [] []
                        , a [ class "button is-medium is-link is-outlined", href "https://github.com/ThunderboltVRS/got-deadpool" ]
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
                        ]
                    ]
                ]
            , div [ class "column is-two-thirds" ]
                [ div [ class "box" ]
                    [ h1 [ class "title" ]
                        [ text "Log Out" ]
                    , p []
                        [ a [ class "button is-medium is-link is-outlined", onClick (LogOut model.uid) ]
                            [ span [ class "icon" ]
                                [ i [ class "fas fa-sign-out-alt" ]
                                    []
                                ]
                            , span []
                                [ text "LogOut" ]
                            ]
                        , br [] []
                        ]
                    ]
                ]
            ]
        ]


characterCard : Model -> Character -> Prediction -> Html Msg
characterCard model character prediction =
    div [ class "column is-full-mobile is-full-tablet is-half-desktop is-half-widescreen is-one-third-fullhd" ]
        [ div [ class "card" ]
            [ div [ class "card-content" ]
                [ div [ class "media" ]
                    [ figure [ class "media-left" ]
                        [ img [ class "image character-pic", src character.pictureUrl ]
                            []
                        ]
                    , div [ class "media-content" ]
                        [ p [ class "title is-4" ]
                            [ text character.name
                            , span [ class "icon character-icon" ]
                                [ i [ class (characterIconClass character) ]
                                    []
                                ]
                            ]
                        , aliveStatusSelection model character prediction
                        , br [] []
                        , br [] []
                        , if prediction.aliveStatus == Dies then
                            episodeSelection model character prediction

                          else
                            div [] []
                        ]

                    -- , div [ class "media-right" ]
                    --     [ span [ class "icon is-large" ]
                    --         [ i [ class (characterIconClass character) ]
                    --             []
                    --         ]
                    --     ]
                    ]
                ]
            ]
        ]


characterIconClass : Character -> String
characterIconClass character =
    case character.aliveStatus of
        Lives ->
            if character.locked && not character.confirmed then
                "fas fa-lock"

            else
                ""

        Dies ->
            "fas fa-skull-crossbones"


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


findPrediction : List Prediction -> Character -> Maybe Prediction
findPrediction predictions character =
    List.filter (\p -> p.characterId == character.id) predictions
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
