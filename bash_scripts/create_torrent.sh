#!/bin/bash
args=("$@")

blurayfolder=${args[0]}
outputlocation=${args[1]}

if [[ "$outputlocation" == "" ]]; then
  foldername=$(basename "$blurayfolder")
  outputlocation="/home/sonic3r/myscripts/outputs/$foldername.torrent"
fi

clear
dotnet /home/sonic3r/myscripts/torrentcreator/TorrentCreator.dll -f "$blurayfolder" -t "https://filelist.io" -p -l 16 -s $outputlocation