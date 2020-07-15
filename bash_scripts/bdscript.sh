#!/bin/bash
args=("$@")
blurayfolder=${args[0]}
outputlocation=${args[1]}
bdinfofolder=${args[2]}

if [[ $bdinfofolder == "" ]]; then
  bdinfofolder="/home/sonic3r/myscripts/bdinfo"
fi

if [[ $blurayfolder == "" ]]; then
  exit 1
fi

if [[ $outputlocation == "" ]]; then
  outputlocation="/home/sonic3r/myscripts/outputs"
fi

echo "$blurayfolder"
foldername=$(basename "$blurayfolder")
clear
dotnet "$bdinfofolder/BDInfo.dll" -p "$blurayfolder" -r "$outputlocation" -o "${foldername}.txt" -b -a -l -y -k -m -j