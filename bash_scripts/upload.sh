#!/bin/bash

path="$1"
location="$2"
kind="$3"

if [[ $path == "" ]]; then
  echo "Invalid path"
  exit
fi

if [[ $location == "" ]]; then
  location="/home/ftpuser/"
fi

if [[ $kind == "" ]]; then
  kind="bluray"
fi

dotnet /home/ftpuser/fluploader/FilelistUploader.dll -p "$path" -l "$location" -c -t $kind