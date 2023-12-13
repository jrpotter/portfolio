#!/usr/bin/env bash

tsc
tailwindcss -i ./src/main.css -o ./dist/main.css
cp ./src/index.html ./dist/index.html
cp ./src/*.svg ./dist
