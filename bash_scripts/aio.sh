args=("$@")
blurayfolder=${args[0]}

clear

cd /home

iso=$(find $blurayfolder -name *.iso)
if [[ $iso != "" ]]; then
  echo $iso
  #dotnet ftpuser/bdextract/BDExtractor.dll -p $blurayfolder/$iso
  #rm $blurayfolder/$iso
fi

#bash bdscript_with_ss.sh $blurayfolder