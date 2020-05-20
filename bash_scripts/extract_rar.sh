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

      rfiles=$(find "$fld" -name *.r*)
      if [[ $rfiles != ""  ]]; then
        for rfile in $rfiles
        do
          rm $rfile
        done
      fi

      dizfile=$(find "$fld" -name *.diz)
      if [[ $dizfile != ""  ]]; then
        rm $dizfile
      fi

      chmod -R 0755 "$output"
    done
  fi
done