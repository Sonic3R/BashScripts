#!/bin/bash

path="$1"
location="$2"
kind="$3"

if [[ $path == "" ]]; then
  echo "Invalid path"
  exit
fi

if [[ $location == "" ]]; then
  location="/home/sonic3r/myscripts/outputs/"
fi

if [[ $kind == "" ]]; then
  kind="bluray"
fi

clear
dotnet /home/sonic3r/myscripts/fluploader/FilelistUploader.dll -p "$path" -l "$location" -c -t $kind