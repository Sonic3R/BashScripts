lookin="/home/r0gu3ptm/rtorrent/download/bluray/"

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

blurays=$(find "$lookin" -mindepth 1 -maxdepth 1 -type d)

if [[ $blurays == "" || $blurays == $lookin ]]; then
   exit 1
fi

for bluray in $blurays; do
  busystatus=$(lsof +D "$bluray")

  if [[ $busystatus != "" ]]; then
    echo "$bluray is busy. Skipping"
    continue
  fi

  bash execute_rclone.sh "$bluray"
done

IFS=$SAVEIFS
