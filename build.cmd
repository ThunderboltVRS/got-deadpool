elm make --optimize ./src/Main.elm --output=./output/js/got-deadpool-1.0.0.js
REM elm make --debug ./src/Main.elm --output=./output/js/got-deadpool-1.0.0.js
CALL elm-minify ./output/js/got-deadpool-1.0.0.js
xcopy /s/y output ..\firebase-hosting\y