#!/bin/bash
args=("$@")
blurayfolder=${args[0]}
outputlocation=${args[1]}
bdinfofolder=${args[2]}

if [[ $bdinfofolder == "" ]]; then
  bdinfofolder="/home/ftpuser/bdinfo"
fi

if [[ $blurayfolder == "" ]]; then
  exit 1
fi

if [[ $outputlocation == "" ]]; then
  outputlocation="/home/ftpuser"
fi

echo "$blurayfolder"
foldername=$(basename "$blurayfolder")
dotnet "$bdinfofolder/BDInfo.dll" -p "$blurayfolder" -r "$outputlocation" -o "${foldername}.txt" -b -a -l -y -k -m

echo Done