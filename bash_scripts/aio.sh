for blurayfolder in "$@"
do
  clear
    
  iso=$(find $blurayfolder -name *.iso)
  if [[ $iso != "" ]]; then
    echo $iso
    dotnet /home/ftpuser/bdextract/BDExtractor.dll -p $blurayfolder/$iso -o $blurayfolder
    rm $blurayfolder/$iso
  fi

  bash /home/bdscript_with_ss.sh $blurayfolder
done
