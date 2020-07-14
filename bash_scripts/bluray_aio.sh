#!/bin/bash

createtorrentdata() {
  name=$2
  replacement=${name// /.}

  # if S01D01 tv disk, then do not create torrent file, is useless
  if [[ $replacement =~ .*S[0-9]+\.?D[0-9]+.* ]]; then
    echo "Won't create torrent for $replacement"
  else
    torrentfile="/home/sonic3r/myscripts/outputs/$replacement.torrent"

    # if contains DISC1, DISC2 etc OR D01 D02 then create torrent from main folder
    if [[ $replacement =~ .*DISC[0-9]+.* || $replacement =~ .*D[0-9]+.* ]]; then
      #skip for now
      echo "Skipping"
    else
      if [[ ! -f $torrentfile ]]; then
        echo "$torrentfile does not exists. Will create it"
        bash /home/sonic3r/myscripts/create_torrent.sh "$1" $torrentfile
      fi
    fi
  fi
}

createbdinfo() {
  bash /home/sonic3r/myscripts/bdscript.sh "$1"
}

createscreens() {
  bash /home/sonic3r/myscripts/ffmpeg.sh "$1" 12
}

getandsaveimdb() {
  folder="$1"
  whereto="$2"
  name=$(basename $folder)

  nfo=""
  original="/home/sonic3r/torrents/rtorrent/$name"
  if [[ -d $original ]]; then
    nfo=$(find "$original" -name *.nfo)
  fi
  
  if [[ $nfo == "" ]]; then
    nfo=$(find "$folder" -name *.nfo)
  fi

  if [[ $nfo != "" ]]; then
   nfocontent=$(cat "$nfo")

    if [[ $whereto == "" ]]; then 
      whereto="/home/sonic3r/myscripts/outputs"
    fi

    imdb=$(echo $nfocontent | grep --only-matching --perl-regexp "tt[0-9]+")
    echo $imdb > "${whereto}/${name}.imdb"
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

getsize(){
  echo $(du -b --max-depth=0 "$1" | cut -f 1)
}

SAVEIFS=$IFS

for blurayfolderitem in "$@"
do
  echo Processing "$blurayfolderitem"

  busystatus=$(lsof "$blurayfolderitem"/*)

  while [[ $busystatus != "" ]]
  do
    echo "$blurayfolderitem is busy"
    sleep 10
    busystatus=$(lsof "$blurayfolderitem"/*)
  done
  
  iso=$(getiso "$blurayfolderitem")
  
  location=$blurayfolderitem
  removeiso=1
  foldername=$(basename "$blurayfolderitem")
  imagefiles=$iso

  IFS=$(echo -en "\n\b")

  if [[ "$imagefiles" != "" ]]; then
    echo "$imagefiles"

    getandsaveimdb "$blurayfolderitem"

    mts=$(find "$blurayfolderitem" -iname *.m2ts)
    if [[ $mts != "" ]]; then
      rm $mts
    fi

    nfo=$(find "$blurayfolderitem" -iname *.nfo)
    if [[ $nfo != "" ]]; then
      rm $nfo
    fi

    jpg=$(find "$blurayfolderitem" -iname *.jpg)
    if [[ $jpg != "" ]]; then
      rm $jpg
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

        dotnet /home/sonic3r/myscripts/bdextract/BDExtractor.dll -p "$imagefile" -o "$location"
        
        # if can extract using above program, if not then use mount style and copy from there
        if [[ $? -eq 0 ]]; then
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

          cp -rf /media/$foldername/* "$location"/

          umount /media/$foldername
          rmdir /media/$foldername

          if [[ $removeiso == 1 ]]; then
            echo Removing $imagefile
            rm "$imagefile"
          fi
            
          createbdinfo "$location"
          createscreens "$location"
          createtorrentdata "$location" $foldername
        fi
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
    createbdinfo "$blurayfolderitem"
    createscreens "$blurayfolderitem"    
    createtorrentdata "$blurayfolderitem" $foldername

    getandsaveimdb "$blurayfolderitem"
  fi

  IFS=$SAVEIFS
done
