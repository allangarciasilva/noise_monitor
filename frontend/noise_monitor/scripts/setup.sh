#!/bin/bash

rm -rf .env proto
cp ../../proto proto -r
cp ../../config.env .env

GEN_FILE=$PWD/lib/gen/api_host.dart
mkdir -p $(dirname $GEN_FILE)

source $PWD/.env
echo "const String API_HOST = \"$API_HOST\";" > $GEN_FILE
echo "const int API_PORT = $API_PORT;" >> $GEN_FILE