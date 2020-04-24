cd /home
for blurayfolder in "$@"
do
  clear
    
  iso=$(find $blurayfolder -name *.iso)
  if [[ $iso != "" ]]; then
    echo $iso
    dotnet ftpuser/bdextract/BDExtractor.dll -p $blurayfolder/$iso -o $blurayfolder
    rm $blurayfolder/$iso
  fi

  bash bdscript_with_ss.sh $blurayfolder
done