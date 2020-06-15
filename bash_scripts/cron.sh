#!/bin/bash

createtorrentdata() {
  name=$2
  replacement=${name// /.}

  # if S01D01 tv disk, then do not create torrent file, is useless
  if [[ $replacement =~ .*S[0-9]+\.?D[0-9]+.* ]]; then
    echo "Won't create torrent for $replacement"
  else
    torrentfile="/home/ftpuser/$replacement.torrent"

    # if contains DISC1, DISC2 etc then create torrent from main folder
    if [[ $replacement =~ .*DISC[0-9]+.* ]]; then
      newname=$(basename "$name")
      replacement=${newname// /.}
      torrentfile="/home/ftpuser/$replacement.torrent"
    fi

    if [[ ! -f $torrentfile ]]; then
      echo "$torrentfile already exists. Skipping"
      bash /home/create_torrent.sh "$1" $torrentfile
    fi
  fi
}

createbdinfo() {
  bash /home/bdscript.sh "$1"
}

createscreens() {
  bash /home/ffmpeg.sh "$1" 12
}

getbdmvfolder() {
  current="$1"
  bdmv=$(find "$current" -iname bdmv -type d)

  if [[ $bdmv == "" ]]; then
    echo ""
  else
    echo "$(dirname "$bdmv")"
  fi
}

getiso(){
  location="$1"

  iso=$(find "$location" -iname *.iso)

  if [[ $iso == "" ]]; then
    iso=$(find "$location" -iname *.img)
  fi

  echo "$iso"
}

foldertolookin=$1
movetoblurayfolder=$2
blurayfolderpath="/home/sonic3r/torrents/rtorrent/bluray/"

if [[ $foldertolookin == "" ]]; then
  foldertolookin="/home/sonic3r/nzbget/downloads/completed"
fi

if [[ $movetoblurayfolder == "" ]]; then
  movetoblurayfolder=1
fi

folders=$(ls $foldertolookin)

if [[ $folders != "" ]]; then
  for blurayfolderitem in $folders
  do
    item="$foldertolookin/$blurayfolderitem"
    echo Processing "$item"
  
    location="$item"
    removeiso=1
    foldername=$(basename "$item")
    imagefiles=$(getiso "$item")

    if [[ $imagefiles != "" ]]; then
      echo "$imagefiles"

      mts=$(find "$item" -iname *.m2ts)
      if [[ $mts != "" ]]; then
        rm "$mts"
      fi

      nfo=$(find "$item" -iname *.nfo)
      if [[ $nfo != "" ]]; then
        rm "$nfo"
      fi

      jpg=$(find "$item" -iname *.jpg)
      if [[ $jpg != "" ]]; then
        rm "$jpg"
      fi

      proof=$(find "$item" -iname proof)
      if [[ $proof != "" ]]; then
        rm -rf "$proof"
      fi

      sample=$(find "$item" -iname sample)
      if [[ $sample != "" ]]; then
        rm -rf "$sample"
      fi

      if [[ $imagefiles != *"3D"* ]];then
        replacement=${item///chd/}
        if [[ $replacement == $item ]]; then
          replacement=${item///mteam/}

          if [[ $replacement == $item ]]; then
            replacement=${item///hdchina/}

            if [[ $replacement != $item ]]; then
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

        echo "Extracting $imagefiles"
        dotnet /home/ftpuser/bdextract/BDExtractor.dll -p "$imagefiles" -o "$location"

        if [ $? -ne 0 ]; then
          continue
        fi

        if [[ $removeiso == 1 ]]; then
          echo Removing "$imagefiles"
          rm "$imagefiles"
        fi

        if [ $? -ne 0 ]; then
          continue
        fi

        createbdinfo "$location"

        if [ $? -ne 0 ]; then
          continue
        fi

        createscreens "$location"

        if [ $? -ne 0 ]; then
          continue
        fi

        createtorrentdata "$location" $foldername

        if [ $? -ne 0 ]; then
          continue
        fi
      else      
        mkdir /media/$foldername
        mount -o loop "$imagefiles" /media/$foldername
  
        createbdinfo /media/$foldername
        createscreens /media/$foldername

        umount /media/$foldername
        rmdir /media/$foldername

        createtorrentdata "$item" $foldername
      fi
    else
      blurayfolder=$(getbdmvfolder "$item")
      if [[ $blurayfolder == "" ]]; then
        continue
      fi

      echo "Bluray folder: $blurayfolder"
      echo "Bluray folder item: $item"

      if [[ $blurayfolder != $item ]];then
        mv $blurayfolder/* "$item"
        rm -rf "$blurayfolder"
      fi
    
      mkv=$(find "$item" -iname *.mkv)

      if [[ $mkv != "" ]]; then
        echo "MKV, not bluray, will skip"
        continue
      fi

      proof=$(find "$item" -iname proof)
      if [[ $proof != "" ]]; then
        rm -rf "$proof"
      fi

      sample=$(find "$item" -iname sample)
      if [[ $sample != "" ]]; then
        rm -rf "$sample"
      fi

      nfo=$(find "$item" -iname *.nfo -maxdepth 1)
      if [[ $nfo != "" ]]; then 
        rm -rf $nfo
      fi

      jpg=$(find "$item" -iname *.jpg -maxdepth 1)
      if [[ $jpg != "" ]]; then 
        rm -rf $jpg
      fi

      createbdinfo "$item"
      createscreens "$item"    
      createtorrentdata "$item" $foldername
    fi

    if [[ $movetoblurayfolder == 1 ]]; then
      mv $item $blurayfolderpath
    fi
  done
fi