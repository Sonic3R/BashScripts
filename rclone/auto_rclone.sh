function getsize {
  folder="$1"

  stats=$(getfolder)
  size=$(du -bs "$folder" | cut -f 1)

  echo $size
}

function setStats {
  folder="$1"

  stats=$(getfolder)
  size=$(getsize "$folder")

  if [[ -f $stats ]]; then
    val=$(cat $stats)
    size=$(($size + $val))
  fi

  echo $size > $stats
}

function uploadedToday {
  stats=$(getfolder)
  awk '{print $1/1024/1024/1024 " GB "}' $stats
}

function getfolder {
    stats=$(date +'%d.%m.%Y').upload
    echo $stats

    if [[ ! -f $stats ]]; then
      echo 0 > $stats
    fi
}

lookin="/home/r0gu3ptm/rtorrent/download/bluray/"

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

blurays=$(find "$lookin" -mindepth 1 -maxdepth 1 -type d)

if [[ $blurays == "" || $blurays == $lookin ]]; then
   exit 1
fi

step=0

for bluray in $blurays; do
  busystatus=$(lsof +D "$bluray")

  if [[ $busystatus != "" ]]; then
    echo "$bluray is busy. Skipping"
    continue
  fi

  curr=$(getsize "$bluray")
  step=$(($step + $curr))

  setStats "$bluray"
  bash execute_rclone.sh "$bluray"
done

IFS=$SAVEIFS

uploaded=$(uploadedToday)
formatstep=$(echo $step | awk '{print $1/1024/1024/1024} " GB "')
uploadqty=$(echo $uploaded | cut -f 1 -d ' ')
diff=$(echo "750 $uploadqty" | awk '{print $1 - $2}')

echo "Current step uploaded: $formatstep"
echo "Total uploaded today: $uploaded"
echo "Remaining: $diff GB"
