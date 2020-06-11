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

getsubfolder(){
  current="$1"
  subfolders=$(ls $current)
  bdmvfound=false
  
  if [[ $subfolders == "" ]];then
    return ""
  fi

  for subfolder in $subfolders
  do
    if [[ basename($subfolder) == "BDMV" || basename($subfolder) == "bdmv" ]]; then
      bdmvfound=true
      break
    fi
  done

  if [[ $bdmvfound == true ]]; then
    return $current
  else
    sub=basename($subfolders)
    return getsubfolder "$1/$sub"
  fi
}

foldertolookin="/home/sonic3r/nzbget/downloads/completed"
folders=$(ls $foldertolookin)

for blurayfolderitem in $folders
do
  echo Processing "$blurayfolderitem"
  
  iso=$(find "$blurayfolderitem" -name *.iso)

  if [[ "$iso" == "" ]]; then
    iso=$(find "$blurayfolderitem" -name *.ISO)
  fi

  if [[ "$iso" == "" ]]; then
    iso=$(find "$blurayfolderitem" -name *.img)
  fi

  if [[ "$iso" == "" ]]; then
    iso=$(find "$blurayfolderitem" -name *.IMG)
  fi
  
  location=$blurayfolderitem
  removeiso=1
  foldername=$(basename "$blurayfolderitem")
  imagefiles=$iso

  if [[ "$imagefiles" != "" ]]; then
    echo "$imagefiles"

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

    proof=$(find "$blurayfolderitem" -name proof)
    if [[ $proof != "" ]]; then
      rm -rf $proof
    fi

    sample=$(find "$blurayfolderitem" -name sample)
    if [[ $sample != "" ]]; then
      rm -rf $sample
    fi

    for imagefile in $imagefiles
    do
      if [[ "$imagefile" != *"3D"* ]];then
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

        dotnet /home/ftpuser/bdextract/BDExtractor.dll -p "$imagefile" -o "$location"

        if [[ $removeiso == 1 ]]; then
          echo Removing $imagefile
          rm "$imagefile"
        fi

        createbdinfo "$location"
        createscreens "$location"
        createtorrentdata "$location" $foldername
      else      
        mkdir /media/$foldername
        mount -o loop "$imagefile" /media/$foldername
  
        createbdinfo /media/$foldername
        createscreens /media/$foldername

        umount /media/$foldername
        rmdir /media/$foldername

        createtorrentdata "$blurayfolderitem" $foldername
      fi
    done
  else
    blurayfolder=$(getsubfolder "$blurayfolderitem")
    if [[ $blurayfolder == "" ]]; then
      continue
    fi

    if [[ $blurayfolder != $blurayfolderitem ]];then
      mv $blurayfolder/* $blurayfolderitem
      rm -rf $blurayfolder
    fi

    createbdinfo "$blurayfolderitem"
    createscreens "$blurayfolderitem"    
    createtorrentdata "$blurayfolderitem" $foldername
  fi
done