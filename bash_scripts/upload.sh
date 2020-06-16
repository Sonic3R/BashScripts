#!/bin/bash

path="$1"
location="$2"

if [[ $path == "" ]]; then
  echo "Invalid path"
  exit
fi

if [[ $location == "" ]]; then
  location="/home/ftpuser/"
fi

dotnet /home/ftpuser/fluploader/FilelistUploader.dll -p "$path" -l "$location"