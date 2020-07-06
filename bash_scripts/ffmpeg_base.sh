#!/bin/bash
args=("$@")

bigfile=${args[0]}
screenshotnum=${args[1]}
outputlocation=${args[2]}
name=${args[3]}

pkgs='ffmpeg'
if ! dpkg -s $pkgs >/dev/null 2>&1; then
  echo $pkgs not installed
  exit 1
fi

if [[ $screenshotnum -eq 0 || $screenshotnum == "" ]]; then
  screenshotnum=6
fi

if [[ "$outputlocation" == "" ]]; then
  outputlocation="/home/ftpuser"
fi

echo Movie found: "$bigfile"

if [[ $bigfile == "" ]]; then
  echo "File not found"
  exit 1
fi

movieseconds=$(ffmpeg -i "$bigfile" 2>&1 | grep "Duration"| cut -d ' ' -f 4 | sed s/,// | sed 's@\..*@@g' | awk '{ split($1, A, ":"); split(A[3], B, "."); print 3600*A[1] + 60*A[2] + B[1] }')
period=$((movieseconds/screenshotnum))

if [[ $period > 300 ]];then
  period=$(( $period - 100 ))
fi

echo "Movie seconds: $movieseconds"
echo "Ss num: $screenshotnum"
echo "Period $period"

if [[ $name == "" ]]; then
  base=$(basename "$bigfile")
  filename="${base%%.*}"
  name="$filename"
fi

i=1;
while [[ $i -le $screenshotnum ]]
do
  seconds=$(( period * i ))
  echo "Seconds $seconds"

  ffmpeg -ss $seconds -t 1 -i "$bigfile" -vcodec png -vframes 1 "${outputlocation}/${name}_${i}.png"
  i=$(( $i + 1 ))
done
