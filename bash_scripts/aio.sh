for blurayfolderitem in "$@"
do
  clear
    
  echo Processing $blurayfolderitem
  
  iso=$(find $blurayfolderitem -name *.iso)
  
  echo $iso

  if [[ $iso != "" ]]; then
    echo $iso
    dotnet /home/ftpuser/bdextract/BDExtractor.dll -p $blurayfolderitem/$iso -o $blurayfolderitem
    rm $blurayfolderitem/$iso
  fi

  bash /home/bdscript_with_ss.sh $blurayfolderitem
done
