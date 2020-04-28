for blurayfolderitem in "$@"
do
  echo Processing $blurayfolderitem
  
  iso=$(find $blurayfolderitem -name *.iso)

  if [[ $iso == "" ]]; then
    iso=$(find $blurayfolderitem -name *.ISO)
  fi
  
  if [[ $iso != "" ]]; then
    echo $iso

    if [[ $iso != *"3D"* ]];then
      dotnet /home/ftpuser/bdextract/BDExtractor.dll -p $iso -o $blurayfolderitem
      rm $iso
    else
      blurayfolderitem=$iso
    fi
  fi  

  bash /home/bdscript_with_ss.sh $blurayfolderitem
done