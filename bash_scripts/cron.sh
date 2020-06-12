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
    echo "End of life"
    return ""
  fi

  for subfolder in $subfolders
  do
    item="$current/$subfolder"
    echo "Look for BD structure in $item"
    base=$(basename "$item")
    if [[ $base == "BDMV" || $base == "bdmv" ]]; then
      bdmvfound=true
      break
    fi
  done

  if [[ $bdmvfound == true ]]; then
    return $current
  else
    sub=$(basename $subfolders)
    echo "Looking in $sub"
    return getsubfolder "$1/$sub"
  fi
}

foldertolookin=$1

if [[ $foldertolookin == "" ]]; then
  foldertolookin="/home/sonic3r/nzbget/downloads/completed"
fi

folders=$(ls $foldertolookin)

for blurayfolderitem in $folders
do
  item="$foldertolookin/$blurayfolderitem"
  echo Processing "$item"
  
  iso=$(find "$item" -name *.iso)

  if [[ "$iso" == "" ]]; then
    iso=$(find "$item" -name *.ISO)
  fi

  if [[ "$iso" == "" ]]; then
    iso=$(find "$item" -name *.img)
  fi

  if [[ "$iso" == "" ]]; then
    iso=$(find "$item" -name *.IMG)
  fi
  
  location="$item"
  removeiso=1
  foldername=$(basename"$item")
  imagefiles=$iso

  if [[ "$imagefiles" != "" ]]; then
    echo "$imagefiles"

    mts=$(find "$item" -name *.m2ts)
    if [[ $mts != "" ]]; then
      rm $mts
    fi

    nfo=$(find "$item" -name *.nfo)
    if [[ $nfo != "" ]]; then
      rm $nfo
    fi

    jpg=$(find "$item" -name *.jpg)
    if [[ $jpg != "" ]]; then
      rm $jpg
    fi

    proof=$(find "$item" -name proof)
    if [[ $proof != "" ]]; then
      rm -rf $proof
    fi

    sample=$(find "$item" -name sample)
    if [[ $sample != "" ]]; then
      rm -rf $sample
    fi

    for imagefile in $imagefiles
    do
      if [[ "$imagefile" != *"3D"* ]];then
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

        createtorrentdata "$item" $foldername
      fi
    done
  else
    blurayfolder=$(getsubfolder "$item")
    if [[ $blurayfolder == "" ]]; then
      continue
    fi

    echo "Bluray folder: $blurayfolder"
    echo "Bluray folder item: $item"

    if [[ $blurayfolder != $item ]];then
      mv $blurayfolder/* "$item"
      rm -rf "$blurayfolder"
    fi
    
    mkv=$(find "$item" -name *.mkv)

    if [[ $mkv != "" ]]; then
      echo "MKV, not bluray, will skip"
      continue
    fi

    createbdinfo "$item"
    createscreens "$item"    
    createtorrentdata "$item" $foldername
  fi
done