read -e -p "Install .NET Core runtime [Y/n]?" installnetcore

if [[ $installnetcore == "y" || $installnetcore == "Y" || $installnetcore == "" ]]; then
  echo "Installing .NET Core runtime"
  package="aspnetcore-runtime-3.1"

  sudo wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb

  sudo add-apt-repository universe
  sudo apt-get update
  sudo apt-get install apt-transport-https
  sudo apt-get update
  sudo apt-get install $package
fi

read -e -p "Install FFMPEG [Y/n]?" installffmpeg

if [[ $installffmpeg == "y" || $installffmpeg == "Y" || $installffmpeg == "" ]]; then
  sudo apt-get install ffmpeg
fi

echo -e -p "Install FTP Server [Y/n] ?" installftp

if [[ $installftp == "y" || $installftp == "Y" || $installftp == "" ]]; then
  echo "Provide FTP user:"
  read ftpuser

  echo "Provide FTP password:"
  read -s password

  echo "Installing ftp server"
  sudo apt-get update
  sudo apt-get install vsftpd
  sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.orig

  echo "Create directory for $ftpuser"
  sudo mkdir /home/$ftpuser

  echo "Add user $ftpuser and set it's password"
  sudo adduser --home=/home/$ftpuser $ftpuser
  echo -e "$password\n$password" | sudo passwd $ftpuser

  echo "Setting permissions"
  sudo mkdir /home/$ftpuser/FTP
  sudo chmod 777 /home/emipro/$ftpuser/FTP

  echo $ftpuser | sudo tee -a /etc/vsftpd.userlist
  cat /etc/vsftpd.userlist

  sudo ufw allow 40000:50000/tcp

  echo "Downloading config model"
  sudo wget https://raw.githubusercontent.com/Sonic3R/BashScripts/master/scripts/vsftpd.conf -O /home/vsftpd.conf
  sudo cp /home/vsftpd.conf /etc/vsftpd.conf
  
  sudo systemctl restart vsftpd
fi

read -e -p "Mount data disk [Y/n] (after mounting disk the system will reboot) ?" mountdatadisk

if [[ $mountdatadisk == "y" || $mountdatadisk == "Y" || $mountdatadisk == "" ]]; then
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

  sudo reboot
fi