echo "Install .NET Core runtime [y/n]?"
read installnetcore

if [ $installnetcore -eq "y" ]; then
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

echo "Install FFMPEG [y/n]?"
read installffmpeg

if [ $installffmpeg -eq "y" ]; then
  sudo apt-get install ffmpeg
fi

echo "Install FTP Server [y/n] ?"
read installftp

if [ $installftp -eq "y" ]; then
  echo "Provide FTP user"
  read ftpuser

  echo "Provide FTP password"
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