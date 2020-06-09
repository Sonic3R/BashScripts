#!/bin/bash
args=("$@")

blurayfolder=${args[0]}
screenshotnum=${args[1]}
outputlocation=${args[2]}

pkgs='ffmpeg'
if ! dpkg -s $pkgs >/dev/null 2>&1; then
  echo $pkgs not installed
  exit 1
fi

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

pkgs='ffmpeg'
if ! dpkg -s $pkgs >/dev/null 2>&1; then
  echo $pkgs not installed
  exit 1
fi

bigfile=$(find "${blurayfolder}/" -printf '%s %p\n'| sort -nr | head -1 | sed 's/^[^ ]* //')

secondmovieseconds=0
anotherfile=''

if [[ $blurayfolder =~ .*3D.* ]]; then
  bigfiles=$(find "${blurayfolder}/" -printf '%s %p\n'| sort -nr | head -2 | sed 's/^[^ ]* //')
  anotherfile=$bigfiles[1]
  secondmovieseconds=$(ffmpeg -i "$anotherfile" 2>&1 | grep "Duration"| cut -d ' ' -f 4 | sed s/,// | sed 's@\..*@@g' | awk '{ split($1, A, ":"); split(A[3], B, "."); print 3600*A[1] + 60*A[2] + B[1] }')
fi

echo Movie found: "$bigfile"
echo Movie found: "$anotherfile"

if [[ $bigfile == "" ]]; then
  echo "File not found"
  exit 1
fi

movieseconds=$(ffmpeg -i "$bigfile" 2>&1 | grep "Duration"| cut -d ' ' -f 4 | sed s/,// | sed 's@\..*@@g' | awk '{ split($1, A, ":"); split(A[3], B, "."); print 3600*A[1] + 60*A[2] + B[1] }')
period=$((movieseconds/screenshotnum))
period=$(( $period - 100 ))

echo "Movie seconds: $movieseconds"
echo "Ss num: $screenshotnum"
echo "Period $period"

i=1;
while [[ $i -le $screenshotnum ]]
do
  seconds=$(( period * i ))
  echo "Seconds $seconds"

  ffmpeg -ss $seconds -t 1 -i "$bigfile" -vcodec png -vframes 1 "${outputlocation}/${foldername}_${i}.png"
  i=$(( $i + 1 ))
done

echo Movie found: "$bigfile"
echo Movie found: "$anotherfile"

echo "Movie seconds: $movieseconds"
echo "Movie 2nd seconds: secondmovieseconds"