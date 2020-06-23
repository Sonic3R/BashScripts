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

ismultidisk() {
  if [[ $1 =~ .*DISC[0-9]+.* ]]; then
    echo 1
  else
    echo 0
  fi
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

busystatus=$(lsof "$folder"/*)

while [[ $busystatus != "" ]]
do
  echo "$folder is busy"
  sleep 10
done

bdmv=$(getbdmvfolder "$folder")
if [[ $bdmv != "" ]]; then
  prevdir=$(dirname $bdmv)

  echo "BDMV location is $bdmv ::: and it should be in $folder"

  if [[ $prevdir != $folder ]]; then
    echo "Moving ${prevdir}/* to ${folder}/"
    mv "${prevdir}"/* "${folder}/"
    rm -rf $prevdir
  fi
fi

echo "Moving $folder to ${movetopath}/"
mv $folder "${movetopath}/"

name=$(basename $folder)
newfolder="$movetopath/$name"
readyfile="${name}.ready"

ready=$(find "$foldertolookin" -name $readyfile | head -n1)

if [[ $ready == "" ]]; then
  bash /home/aio.sh "$newfolder"
else
  rm $ready
fi

multi=$(ismultidisk "$newfolder")

if [[ $multi == 0 ]]; then
  bash /home/upload.sh "$newfolder"
fi