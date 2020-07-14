#!/bin/bash

item="$1"
saveto="/home/sonic3r/myscripts"

pkgs='mediainfo'
if ! dpkg -s $pkgs >/dev/null 2>&1; then
  echo $pkgs not installed
  exit 1
fi

if [[ $item == "" ]]; then
  echo "No item specified"
  exit 1
fi

mkv="$item"
isfolder=0

if [[ -d $item ]]; then
  mkv=$(find "${item}/" -type f \( -iname *.mkv \) -printf '%s %p\n'| sort -nr | head -1 | sed 's/^[^ ]* //')
  isfolder=1
fi

if [[ $mkv == "" || ! -f $mkv ]]; then
  echo "Mkv not found"
  exit 1
fi

base=$(basename "$mkv")
filename="${base%%.*}"
echo "$filename"

mediainfo $mkv --LogFile="${saveto}/${filename}.mediainfo"
bash ffmpeg_base.sh $mkv 6 $saveto $filename
torrentfile="${saveto}/${filename}.torrent"

if [[ $isfolder == 1 ]]; then
  bash /home/create_torrent.sh "$item" $torrentfile
  bash /home/upload.sh "$item" $saveto "movie"
else
  bash /home/create_torrent.sh "$mkv" $torrentfile
  bash /home/upload.sh "$mkv" $saveto "movie"
fi