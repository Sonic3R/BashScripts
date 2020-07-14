#!/bin/bash

folder="$1"

if [[ $folder == "" ]]; then
  echo "$folder not found ";
  exit
fi

bash /home/sonic3r/myscripts/bluray_aio.sh "$folder"
bash /home/sonic3r/myscripts/upload.sh "$folder"