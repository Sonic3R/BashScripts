#!/bin/bash
args=("$@")

blurayfolder=${args[0]}
screenshotnum=${args[1]}
outputlocation=${args[2]}

if [[ "$blurayfolder" == "" ]]; then
  echo No bluray folder specified
  exit 1
fi

foldername=$(basename "$blurayfolder")
bash 

if [[ $screenshotnum -eq 0 || $screenshotnum == "" ]]; then
  screenshotnum=6
fi

if [[ "$outputlocation" == "" ]]; then
  outputlocation="/home/sonic3r/myscripts/outputs"
fi

bigfile=$(find "${blurayfolder}/" -type f \( -iname *.m2ts -o -iname *.ssif \) -printf '%s %p\n'| sort -nr | head -1 | sed 's/^[^ ]* //')

echo Movie found: "$bigfile"

if [[ $bigfile == "" ]]; then
  echo "File not found"
  exit 1
fi

bash /home/sonic3r/myscripts/ffmpeg_base.sh $bigfile $screenshotnum $outputlocation $foldername