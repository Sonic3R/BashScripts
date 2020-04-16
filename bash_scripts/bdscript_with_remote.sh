#!/bin/bash
mntdisk="/datadrive"
isodir="/mnt/iso"
outputftp="/home/ftpuser"

remotepath="/downloads/extract"
remoteuser="Sonic3R"
remoteport=23437
remoteip='185.56.20.10'
screenshotnum=0

clear

if [[ ! -d "$mntdisk" ]]; then
  echo "$mntdisk does not exist !"
  exit 1
fi

echo Provide iso file name
read isofile

clear

echo Provide folder name to extract ISO in
read foldername

clear

echo Provide output folder
read outputftp

clear 

read -e -p "Generate Screens ? [Y/n]" generatescreens


if [[ $generatescreens == "y" || $generatescreens == "Y" || $generatescreens == "" ]]; then
  echo "Number of screens"
  read ssnum
  
  if [[ $ssnum -eq 0 ]]; then
    screenshotnum=3
  else
    screenshotnum=$ssnum
  fi
fi

clear

read -e -p "Use other host ? [y/N]" useotherhost

if [[ $useotherhost == "Y" || $useotherhost == "y" ]]; then
  remoteuser="r0gu3ptm"
  remoteport=24370
  remoteip='88.198.43.92'
fi

clear 

[ ! -d "$isodir" ] && sudo mkdir "$isodir"

clear

echo "Provide remote output folder (default: /downloads/extract)"
read remotepath

if [[ $remotepath == "" ]]; then
  if [[ $useotherhost == "Y" || $useotherhost == "y" ]]; then
    remotepath="/home/r0gu3ptm/rtorrent/download/0000unpack"
  else
    remotepath="/downloads/extract"
  fi

  echo "$remotepath will be used"
fi

if [ ! -f "$mntdisk/$isofile" ]; then
  echo Copying ISO from remote 
  scp -r -P $remoteport $remoteuser@$remoteip:$remotepath/$isofile $mntdisk/$isofile
fi

if [[ $? -eq 1 ]]; then
  echo Copying ISO failed
  exit 1;
fi

clear

if [ ! -d "$mntdisk/$foldername" ]; then
  echo Mounting $mntdisk/$isofile
  sudo mount -o loop $mntdisk/$isofile $isodir

  if [[ $? -eq 1 ]]; then
    echo Mounting ISO failed
    exit 1;
  fi

  clear

  echo Creating $foldername
  mkdir $mntdisk/$foldername

  if [[ $? -eq 1 ]]; then
    echo Creating folder $foldername failed
    exit 1;
  fi

  clear

  echo Copying ISO content to $foldername
  scp -r $isodir/* $mntdisk/$foldername

  if [[ $? -eq 1 ]]; then
    echo Copying ISO content to $foldername failed
    exit 1;
  fi

  clear

  echo Unmount ISO
  sudo umount $isodir

  if [[ $? -eq 1 ]]; then
    echo Unmounting ISO failed
    exit 1;
  fi

  clear
fi

clear

echo Generate bd info
if [[ -f "${outputftp}/${foldername}.txt" ]]; then
  read -e -p "Generate BDInfo again ? [Y/n]" readbdinfo
  if [[ $readbdinfo == "y" || $readbdinfo == "Y" || $readbdinfo == "" ]]; then
    dotnet $mntdisk/bdinfo/BDInfo.dll -p $mntdisk/$foldername -r $outputftp -o "${foldername}.txt" -g -b -a -l -y -k -m
  fi
else
  dotnet $mntdisk/bdinfo/BDInfo.dll -p $mntdisk/$foldername -r $outputftp -o "${foldername}.txt" -g -b -a -l -y -k -m
fi

if [[ $? -eq 1 ]]; then
  echo Generating info failed
  exit 1;
fi

clear

if [[ $generatescreens == "y" || $generatescreens == "Y" || $generatescreens == "" ]]; then
  pkgs='ffmpeg'
  if ! dpkg -s $pkgs >/dev/null 2>&1; then
    echo Installing $pkgs
    sudo apt-get install $pkgs
  fi

  bigfile="$(find $mntdisk/$foldername/ -printf '%s %p\n'| sort -nr | head -1 | sed 's/^[^ ]* //')"

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

    ffmpeg -ss $seconds -t 1 -i $bigfile -vcodec png -vframes 1 "${outputftp}/${foldername}_${i}.png"
    i=$(( $i + 1 ))
  done
fi

if [[ $? -eq 1 ]]; then
  echo Generating screens failed
  exit 1;
fi

clear

echo Copying to seedbox
scp -r -P $remoteport $mntdisk/$foldername $remoteuser@$remoteip:$remotepath/

if [[ $? -eq 1 ]]; then
  echo Copying to seedbox failed
  exit 1;
fi

clear

echo Delete $foldername
sudo rm -rf $mntdisk/$foldername

if [[ $? -eq 1 ]]; then
  echo Removing $foldername failed
  exit 1;
fi

echo Delete $isofile
sudo rm $mntdisk/$isofile

if [[ $? -eq 1 ]]; then
  echo Removing $isofile failed
  exit 1;
fi

clear

echo Done job