#!/bin/bash

path="$1"

if [[ $path == "" ]]; then
  path="/home/sonic3r/myscripts";
fi

clear
my_array=(bdscript.sh bluray_autoupload.sh cron.sh extract_rar.sh ffmpeg.sh bluray_aio.sh create_torrent.sh extract_iso.sh ffmpeg_base.sh upload.sh)
url="https://raw.githubusercontent.com/Sonic3R/Scripts/ubuntu_hetzner/bash_scripts"

for i in "${my_array[@]}"; 
do
  full_url="${url}/${i}"
  full_path="${path}/${i}"

  if [[ -f $full_path ]]; then
    rm $full_path
  fi

  wget $full_url $full_path
  
  dos2unix $full_path
  chmod +x $full_path
done