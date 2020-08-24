function setStats {
  bluray="$1"

  stats=$(date +'%d.%m.%Y').upload
  bluray=.
  size=$(du -bs "$bluray" | cut -f 1)

  if [[ -f $stats ]]; then
    val=$(cat $stats)
    echo $val
    size=$(($size + $val))
  fi

  echo $size > $stats 
}

lookin="/home/r0gu3ptm/rtorrent/download/bluray/"

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

blurays=$(find "$lookin" -mindepth 1 -maxdepth 1 -type d)

if [[ $blurays == "" || $blurays == $lookin ]]; then
   exit 1
fi

stats=$(date +'%d.%m.%Y').upload
size=0

for bluray in $blurays; do
  busystatus=$(lsof +D "$bluray")

  if [[ $busystatus != "" ]]; then
    echo "$bluray is busy. Skipping"
    continue
  fi

  setStats "$bluray"
  bash execute_rclone.sh "$bluray"
done

IFS=$SAVEIFS
