#!/bin/bash
for blurayfolderitem in "$@"
do
  echo Processing "$blurayfolderitem"
  
  iso=$(find "$blurayfolderitem" -name *.iso)

  if [[ "$iso" == "" ]]; then
    iso=$(find "$blurayfolderitem" -name *.ISO)
  fi
  
  location = $blurayfolderitem
  removeiso = 1
  foldername=$(basename "$blurayfolderitem")

  if [[ "$iso" != "" ]]; then
    echo "$iso"

    if [[ "$iso" != *"3D"* ]];then
      replacement=${blurayfolderitem///chd/}
      if [[ $replacement == $blurayfolderitem ]]; then
        replacement=${blurayfolderitem///mteam/}

        if [[ $replacement == $blurayfolderitem ]]; then
          replacement=${blurayfolderitem///hdchina/}

          if [[ $replacement != $blurayfolderitem ]]; then
            location = $replacement
            removeiso = 0
          fi
        else
          location = $replacement
          removeiso = 0
        fi
      else
        location = $replacement
        removeiso = 0
      fi

      dotnet /home/ftpuser/bdextract/BDExtractor.dll -p "$iso" -o "$location"

      if [[ $removeiso == 1 ]]; then
        echo Removing $iso
        rm "$iso"
      fi

      bash /home/bdscript_with_ss.sh "$location"

      dotnet /home/ftpuser/torrentcreator/TorrentCreator.dll -f "$location" -t "https://filelist.io" -p -l 16 -s "/home/ftpuser/$foldername.torrent"
    else      
      mkdir /media/$foldername
      mount -o loop "$iso" /media/$foldername
  
      bash /home/bdscript_with_ss.sh /media/$foldername

      umount /media/$foldername
      rmdir /media/$foldername

      dotnet /home/ftpuser/torrentcreator/TorrentCreator.dll -f "$blurayfolderitem" -t "https://filelist.io" -p -l 16 -s "/home/ftpuser/$foldername.torrent"
    fi
  else
    bash /home/bdscript_with_ss.sh "$blurayfolderitem"
    dotnet /home/ftpuser/torrentcreator/TorrentCreator.dll -f "$blurayfolderitem" -t "https://filelist.io" -p -l 16 -s "/home/ftpuser/$foldername.torrent"
  fi
done