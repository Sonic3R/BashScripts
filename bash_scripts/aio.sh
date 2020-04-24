for blurayfolderitem in "$@"
do
  echo Processing $blurayfolderitem
  
  iso=$(find $blurayfolderitem -name *.iso)
  
  echo $iso

  if [[ $iso != "" ]]; then
    echo $iso
    dotnet /home/ftpuser/bdextract/BDExtractor.dll -p $blurayfolderitem/$iso -o $blurayfolderitem
    rm $blurayfolderitem/$iso

    bash /home/bdscript_with_ss.sh $blurayfolderitem
  fi  
done