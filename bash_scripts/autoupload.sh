#!/bin/bash

getbdmvfolder() {
  current="$1"
  bdmv=$(find "$current" -iname bdmv -type d)

  if [[ $bdmv == "" ]]; then
    echo ""
  else
    echo "$bdmv"
  fi
}

getsize(){
  echo $(du -b --max-depth=0 "$1" | cut -f 1)
}

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

size=$(getsize "$folder")
prevsize=0
  
while [[ $prevsize != $size ]]
do
  echo "Not done. Will rerty in 5 secs"
  sleep 5
  prevsize=$(getsize "$folder")
done

bdmv=$(getbdmvfolder "$folder")
if [[ $bdmv != "" ]]; then
  prevdir=$(dirname $bdmv)

  if [[ $prevdir != $folder ]]; then
    mv "${prevdir}/*" "${folder}/"
    rm -rf $prevdir
  fi
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