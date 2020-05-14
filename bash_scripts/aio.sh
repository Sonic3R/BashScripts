#!/bin/bash

createtorrentdata() {
  name=$2
  replacement=${name// /.}

  # if S01D01 tv disk, then do not create torrent file, is useless
  if [[ $replacement =~ .*S[0-9]+\.?D[0-9]+.* ]]; then
      echo "Won't create torrent for $replacement"
  else
      bash create_torrent.sh "$1" "/home/ftpuser/$replacement.torrent"
      #dotnet /home/ftpuser/torrentcreator/TorrentCreator.dll -f "$1" -t "https://filelist.io" -p -l 16 -s "/home/ftpuser/$replacement.torrent"
  fi  
}

createbdinfo() {
  bash /home/bdscript.sh "$1"
}

createscreens() {
  bash /home/ffmpeg.sh "$1" 6
}

for blurayfolderitem in "$@"
do
  echo Processing "$blurayfolderitem"
  
  iso=$(find "$blurayfolderitem" -name *.iso)

  if [[ "$iso" == "" ]]; then
    iso=$(find "$blurayfolderitem" -name *.ISO)
  fi
  
  location=$blurayfolderitem
  removeiso=1
  foldername=$(basename "$blurayfolderitem")

  if [[ "$iso" != "" ]]; then
    echo "$iso"

    mts=$(find "$blurayfolderitem" -name *.m2ts)
    if [[ $mts != "" ]]; then
      rm $mts
    fi

    nfo=$(find "$blurayfolderitem" -name *.nfo)
    if [[ $nfo != "" ]]; then
      rm $nfo
    fi

    jpg=$(find "$blurayfolderitem" -name *.jpg)
    if [[ $jpg != "" ]]; then
      rm $jpg
    fi

    if [[ "$iso" != *"3D"* ]];then
      replacement=${blurayfolderitem///chd/}
      if [[ $replacement == $blurayfolderitem ]]; then
        replacement=${blurayfolderitem///mteam/}

        if [[ $replacement == $blurayfolderitem ]]; then
          replacement=${blurayfolderitem///hdchina/}

          if [[ $replacement != $blurayfolderitem ]]; then
            location=$replacement
            removeiso=0
          fi
        else
          location=$replacement
          removeiso=0
        fi
      else
        location=$replacement
        removeiso=0
      fi

      dotnet /home/ftpuser/bdextract/BDExtractor.dll -p "$iso" -o "$location"

      if [[ $removeiso == 1 ]]; then
        echo Removing $iso
        rm "$iso"
      fi

      createbdinfo "$location"
      createscreens "$location"
      createtorrentdata "$location" $foldername
    else      
      mkdir /media/$foldername
      mount -o loop "$iso" /media/$foldername
  
      createbdinfo /media/$foldername
      createscreens /media/$foldername

      umount /media/$foldername
      rmdir /media/$foldername

      createtorrentdata "$blurayfolderitem" $foldername
    fi
  else
    createbdinfo "$blurayfolderitem"
    createscreens "$blurayfolderitem"

    
    createtorrentdata "$blurayfolderitem" $foldername
  fi
done