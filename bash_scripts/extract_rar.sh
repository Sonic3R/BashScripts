#!/bin/bash

for fld in "$@"
do
  rarfiles=$(find "$fld" -name *.rar)

  if [[ $rarfiles == "" ]]; then
    rarfiles=$(find "$fld" -name *.RAR)
  fi

  if [[ $rarfiles != "" ]]; then 
    for rar in $rarfiles
    do
      output=$(dirname "${rar}")

      7z x "$rar" -oc:"$output/"

      if [[ $? -eq 0 ]]; then
        rm $rar
      fi

      chmod -R 0755 "$output"

      rm "$output/*.r*"
      rm "$output/*.diz"
    done
  fi
done