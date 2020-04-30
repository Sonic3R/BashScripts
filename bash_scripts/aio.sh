for blurayfolderitem in "$@"
do
  echo Processing "$blurayfolderitem"
  
  iso=$(find "$blurayfolderitem" -name *.iso)

  if [[ "$iso" == "" ]]; then
    iso=$(find "$blurayfolderitem" -name *.ISO)
  fi
  
  if [[ "$iso" != "" ]]; then
    echo "$iso"

    if [[ "$iso" != *"3D"* ]];then
      dotnet /home/ftpuser/bdextract/BDExtractor.dll -p "$iso" -o "$blurayfolderitem"
      rm "$iso"

      bash /home/bdscript_with_ss.sh "$blurayfolderitem"
    else      
      foldername=$(basename "$blurayfolderitem")
      mkdir /media/$foldername
      mount -o loop "$iso" /media/$foldername
  
      bash /home/bdscript_with_ss.sh /media/$foldername

      umount /media/$foldername
      rmdir /media/$foldername
    fi
  else
    bash /home/bdscript_with_ss.sh "$blurayfolderitem"
  fi
done