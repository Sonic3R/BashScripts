#!/bin/bash

foldertolookin="$1"
movetopath="/home/sonic3r/torrents/rtorrent/bluray"

if [[ $foldertolookin == "" ]]; then
  foldertolookin="/home/sonic3r/torrents/rtorrent/blurayready"
fi

if [[ ! -d $foldertolookin ]]; then
  echo "$foldertolookin is not directory"
  exit
fi

folder=$(find "$foldertolookin" -mindepth 1 -maxdepth 1 -type d | head -n1)

if [[ $folder == "" ]]; then
  echo "Nothing to process"
  exit
fi

mv $folder "$movetopath/"

name=$(basename $folder)
newfolder="$movetopath/$name"
readyfile="${name}.ready"

ready=$(find "$foldertolookin" -name $readyfile | head -n1)

if [[ $ready == "" ]]; then
  bash /home/aio.sh "$newfolder"
else
  rm $ready
fi

bash /home/upload.sh "$newfolder"