clear
echo "Location of bdscript (/home/ftpuser/bdinfo)"
read bdinfofolder

if [[ $bdinfofolder == "" ]]; then
  bdinfofolder="/home/ftpuser/bdinfo"
fi

echo "Location of bluray folder"
read blurayfolder

if [[ $blurayfolder == "" ]]; then
  exit 1
fi

echo "Location to save results and screens (/home/ftpuser)"
read outputlocation

if [[ $outputlocation == "" ]]; then
  outputlocation="/home/ftpuser"
fi

foldername=$(basename $blurayfolder)
dotnet $bdinfofolder/BDInfo.dll -p $blurayfolder -r $outputlocation -o "${foldername}.txt" -g -b -a -l -y -k -m

echo "Number of screens (default: 3)"
read ssnum

screenshotnum=3

if [[ $ssnum -eq 0 || $ssnum == "" ]]; then
  screenshotnum=3
else
  screenshotnum=$ssnum
fi

pkgs='ffmpeg'
if ! dpkg -s $pkgs >/dev/null 2>&1; then
  echo $pkgs not installed
  exit 1
fi

bigfile="$(find $blurayfolder/ -printf '%s %p\n'| sort -nr | head -1 | sed 's/^[^ ]* //')"

echo "Movie found: $bigfile"

movieseconds=$(ffmpeg -i $bigfile 2>&1 | grep "Duration"| cut -d ' ' -f 4 | sed s/,// | sed 's@\..*@@g' | awk '{ split($1, A, ":"); split(A[3], B, "."); print 3600*A[1] + 60*A[2] + B[1] }')
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

  ffmpeg -ss $seconds -t 1 -i $bigfile -vcodec png -vframes 1 "${outputlocation}/${foldername}_${i}.png"
  i=$(( $i + 1 ))
done