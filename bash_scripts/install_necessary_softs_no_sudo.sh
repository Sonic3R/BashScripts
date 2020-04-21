echo "Your current user name"
read currentuser

read -e -p "Install .NET Core runtime [Y/n]?" installnetcore

if [[ $installnetcore == "y" || $installnetcore == "Y" || $installnetcore == "" ]]; then
  clear
  . /etc/os-release
  ubuntuos=$VERSION_ID

  if [[ $ubuntuos == "10" ]];then
    ubuntuos=19.10
  fi

  echo "Installing .NET Core runtime: $ubuntuos"
  package="aspnetcore-runtime-3.1"

  wget https://packages.microsoft.com/config/ubuntu/$ubuntuos/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  dpkg -i packages-microsoft-prod.deb

  add-apt-repository universe
  apt-get update
  apt-get install apt-transport-https
  apt-get update
  echo -e "Y" | apt-get install $package
fi

read -e -p "Install FFMPEG [Y/n]?" installffmpeg

if [[ $installffmpeg == "y" || $installffmpeg == "Y" || $installffmpeg == "" ]]; then
  clear
  echo -e "Y" | apt-get install ffmpeg
fi

read -e -p "Install unrar [Y/n]?" installunrar

if [[ $installunrar == "y" || $installunrar == "Y" || $installunrar == "" ]]; then
  clear
  echo -e "Y" | apt-get install unrar
fi

read -e -p "Install mktorrent [Y/n]?" installmktorrent

if [[ $installmktorrent == "y" || $installmktorrent == "Y" || $installmktorrent == "" ]]; then
  clear
  echo -e "Y" | apt-get install mktorrent
fi

read -e -p "Install FTP Server [Y/n] ?" installftp

if [[ $installftp == "y" || $installftp == "Y" || $installftp == "" ]]; then
  clear
  echo "Provide FTP user:"
  read ftpuser

  echo "Provide FTP password:"
  read -s password

  echo "Installing ftp server"
  apt-get update
  echo -e "Y" | apt-get install vsftpd
  cp /etc/vsftpd.conf /etc/vsftpd.conf.orig

  echo "Create directory for $ftpuser"
  mkdir /home/$ftpuser

  echo "Add user $ftpuser and set it's password"
  echo -e "$password\n$password\n\n\n\n\n\ny" | adduser --home=/home/$ftpuser $ftpuser
  #echo -e "$password\n$password" | passwd $ftpuser

  echo "Setting permissions"
  chmod 777 /home/$ftpuser

  chown $ftpuser /home/$ftpuser
  chown $currentuser /home/$ftpuser

  echo $ftpuser | tee -a /etc/vsftpd.userlist
  cat /etc/vsftpd.userlist

  ufw allow 40000:50000/tcp

  echo "Downloading config model"
  wget https://raw.githubusercontent.com/Sonic3R/Scripts/master/bash_scripts/vsftpd.conf -O /home/vsftpd.conf
  cp /home/vsftpd.conf /etc/vsftpd.conf
  
  systemctl restart vsftpd
fi

read -e -p "Mount data disk [Y/n] (after mounting disk the system will reboot) ?" mountdatadisk

if [[ $mountdatadisk == "y" || $mountdatadisk == "Y" || $mountdatadisk == "" ]]; then
  clear
  dmesg | grep SCSI

  echo "Partition number. ex 1..2..3"
  read partnumber

  echo "Provide folder name for mounting"
  read datadrivefolder

  (
  echo o
  echo n
  echo p
  echo $partnumber
  echo
  echo
  echo w
  ) | fdisk /dev/sdc

  mkfs -t ext4 /dev/sdc$partnumber
  mkdir /$datadrivefolder
  mount /dev/sdc$partnumber /$datadrivefolder

  partitionuid=$(blkid -o value -s UUID /dev/sdc$partnumber)
  line="UUID=$partitionuid\t/$datadrivefolder\text4\tdefaults,nofail\t1 2"
  echo -e $line >> /etc/fstab

  chown $currentuser /$datadrivefolder

  reboot
fi

read -e -p "Copy bdinfo bash script [Y/n] ?" bdinfoscript
if [[ $bdinfoscript == "y" || $bdinfoscript == "Y" || $bdinfoscript == "" ]];then
  read -e -p "Provide location to save" bdinfolocation

  wget https://raw.githubusercontent.com/Sonic3R/Scripts/master/bash_scripts/bdscript_with_remote.sh -O $bdinfolocation/bdscript.sh
fi

read -e -p "Install seedbox [Y/n] ?" installseedbox
if [[ $installseedbox == "y" || $installseedbox == "Y" || $installseedbox == "" ]];then
   bash <(wget -O- -q https://raw.githubusercontent.com/liaralabs/swizzin/master/setup.sh)
fi