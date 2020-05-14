#!/bin/bash
args=("$@")

blurayfolder=${args[0]}
outputlocation=${args[1]}

if [[ "$outputlocation" == "" ]]; then
  foldername=$(basename "$blurayfolder")
  outputlocation="/home/ftpuser/$foldername.torrent"
fi

dotnet /home/ftpuser/torrentcreator/TorrentCreator.dll -f "$blurayfolder" -t "https://filelist.io" -p -l 16 -s $outputlocation