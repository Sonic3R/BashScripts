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

if [[ $screenshotnum -eq 0 || $screenshotnum == "" ]]; then
  screenshotnum=6
fi

if [[ "$outputlocation" == "" ]]; then
  outputlocation="/home/ftpuser"
fi

bigfile=$(find "${blurayfolder}/" -type f \( -iname *.m2ts -o -iname *.ssif -o -iname *.mkv \) -printf '%s %p\n'| sort -nr | head -1 | sed 's/^[^ ]* //')

echo Movie found: "$bigfile"

if [[ $bigfile == "" ]]; then
  echo "File not found"
  exit 1
fi

bash /home/r0gu3ptm/myscripts/ffmpeg_base.sh $bigfile $screenshotnum $outputlocation $foldername
