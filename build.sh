#!/usr/bin/env bash

tailwindcss -i ./src/main.css -o ./dist/main.css
cp ./src/index.html ./dist/index.html
cp -a ./imgs ./dist
