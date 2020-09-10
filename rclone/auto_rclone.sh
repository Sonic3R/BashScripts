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
  content=$(cat $stats)
  result=$(getingb $content)
  #result=$(awk '{print $1/1024/1024/1024 " GB "}' $stats)

  echo $result
}

function getingb {
  content=$1
  result=$(echo $content | awk '{print $1/1024/1024/1024 " GB "}')

  echo $result
}

function getfolder {
    stats=$(date +'%d.%m.%Y').upload
    echo $stats

    if [[ ! -f $stats ]]; then
      echo 0 > $stats
    fi
}

function getBluray {
  bl="$1"
  iso=$(find "$bl" -maxdepth 1 -mindepth 1 -type f -iname *.iso)
  if [[ $iso == "" ]]; then
    echo "$bl"
  else
    echo "$iso"
  fi
}

lookin="$1"
top=$2

if [[ $lookin == "" ]]; then
	lookin="/home/r0gu3ptm/rtorrent/download/bluray/"
fi

if [[ $top == "" ]]; then
	top=0
fi

echo "Bucuresti456!" | sudo -S chown r0gu3ptm -R $lookin

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

if [[ $top -gt 0 ]]; then
	blurays=$(find "$lookin" -mindepth 1 -maxdepth 1 -type d | head -${top})
else
	blurays=$(find "$lookin" -mindepth 1 -maxdepth 1 -type d)
fi

if [[ $blurays == "" || $blurays == $lookin ]]; then
   exit 1
fi

step=0
arr=($blurays)
len=${#arr[@]}
#len=$(find "$lookin" -mindepth 1 -maxdepth 1 -type d | wc -l)
index=0

for bluray in $blurays; do
  busystatus=$(lsof +D "$bluray")
  index=$((index + 1))

  clear
  echo Step ${index}/${len} 
  if [[ $busystatus != "" ]]; then
    echo "$bluray is busy. Skipping"
    continue
  fi

  name=$(basename "$bluray")
  curr=$(getsize "$bluray")
  step=$(($step + $curr))

  setStats "$bluray"
  disc=$(getBluray "$bluray")
  
  if [[ ! -f /home/r0gu3ptm/myscripts/${name}.txt ]]; then
    /home/r0gu3ptm/myscripts/bdinfo/BDInfo -p "$disc" -r /home/r0gu3ptm/myscripts/ -o "${name}.txt" -b -a -l -y -k -m -j
  fi
  
  if [ $? -ne 0 ]; then
    echo "Error: going to next item"
		continue
	fi
  
  bash execute_rclone.sh "$bluray"
done

IFS=$SAVEIFS

uploaded=$(uploadedToday)
formatstep=$(getingb $step)
uploadqty=$(echo $uploaded | cut -f 1 -d ' ')
diff=$(echo "750 $uploadqty" | awk '{print $1 - $2}')

echo "Current step uploaded: $formatstep"
echo "Total uploaded today: $uploaded"
echo "Remaining: $diff GB"
df
