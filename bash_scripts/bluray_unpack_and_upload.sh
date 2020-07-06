#!/bin/bash

folder="$1"

if [[ $folder == "" ]]; then
  echo "$folder not found ";
  exit
fi

bash /home/aio.sh "$folder"
bash /home/upload.sh "$folder"