#!/bin/bash

path="$1"
location="$2"
watch="$3"

if [[ $path == "" ]]; then
  echo "Invalid path"
  exit
fi

if [[ $location == "" ]]; then
  location="/home/ftpuser/"
fi

if [[ $watch == "" ]]; then
  watch="/home/sonic3r/bluraywatcher/"
fi

#dotnet /home/ftpuser/fluploader/FilelistUploader.dll -p "$path" -l "$location" -w "$watch"
dotnet /home/ftpuser/fluploader/FilelistUploader.dll -p "$path" -l "$location" -c