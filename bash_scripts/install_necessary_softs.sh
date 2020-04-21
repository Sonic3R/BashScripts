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

  sudo wget https://packages.microsoft.com/config/ubuntu/$ubuntuos/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb

  sudo add-apt-repository universe
  sudo apt-get update
  sudo apt-get install apt-transport-https
  sudo apt-get update
  echo -e "Y" | sudo apt-get install $package
fi

read -e -p "Install FFMPEG [Y/n]?" installffmpeg

if [[ $installffmpeg == "y" || $installffmpeg == "Y" || $installffmpeg == "" ]]; then
  clear
  echo -e "Y" | sudo apt-get install ffmpeg
fi

read -e -p "Install unrar [Y/n]?" installunrar

if [[ $installunrar == "y" || $installunrar == "Y" || $installunrar == "" ]]; then
  clear
  echo -e "Y" | sudo apt-get install unrar
fi

read -e -p "Install mktorrent [Y/n]?" installmktorrent

if [[ $installmktorrent == "y" || $installmktorrent == "Y" || $installmktorrent == "" ]]; then
  clear
  echo -e "Y" | sudo apt-get install mktorrent
fi

read -e -p "Install FTP Server [Y/n] ?" installftp

if [[ $installftp == "y" || $installftp == "Y" || $installftp == "" ]]; then
  clear
  echo "Provide FTP user:"
  read ftpuser

  echo "Provide FTP password:"
  read -s password

  echo "Installing ftp server"
  sudo apt-get update
  echo -e "Y" | sudo apt-get install vsftpd
  sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.orig

  echo "Create directory for $ftpuser"
  sudo mkdir /home/$ftpuser

  echo "Add user $ftpuser and set it's password"
  echo -e "$password\n$password\n\n\n\n\n\ny" | sudo adduser --home=/home/$ftpuser $ftpuser
  #echo -e "$password\n$password" | sudo passwd $ftpuser

  echo "Setting permissions"
  sudo chmod 777 /home/$ftpuser

  sudo chown $ftpuser /home/$ftpuser
  sudo chown $currentuser /home/$ftpuser

  echo $ftpuser | sudo tee -a /etc/vsftpd.userlist
  cat /etc/vsftpd.userlist

  sudo ufw allow 40000:50000/tcp

  echo "Downloading config model"
  sudo wget https://raw.githubusercontent.com/Sonic3R/Scripts/master/bash_scripts/vsftpd.conf -O /home/vsftpd.conf
  sudo cp /home/vsftpd.conf /etc/vsftpd.conf
  
  sudo systemctl restart vsftpd
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
  ) | sudo fdisk /dev/sdc

  sudo mkfs -t ext4 /dev/sdc$partnumber
  sudo mkdir /$datadrivefolder
  sudo mount /dev/sdc$partnumber /$datadrivefolder

  partitionuid=$(sudo blkid -o value -s UUID /dev/sdc$partnumber)
  line="UUID=$partitionuid\t/$datadrivefolder\text4\tdefaults,nofail\t1 2"
  echo -e $line >> /etc/fstab

  sudo chown $currentuser /$datadrivefolder

  sudo reboot
fi

read -e -p "Copy bdinfo bash script [Y/n] ?" bdinfoscript
if [[ $bdinfoscript == "y" || $bdinfoscript == "Y" || $bdinfoscript == "" ]];then
  read -e -p "Provide location to save" bdinfolocation

  sudo wget https://raw.githubusercontent.com/Sonic3R/Scripts/master/bash_scripts/bdscript_with_remote.sh -O $bdinfolocation/bdscript.sh
fi