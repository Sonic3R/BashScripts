#!/bin/bash

for fld in "$@"
do
  isofiles=$(find "$fld" -name *.iso)

  if [[ $isofiles == "" ]]; then
    isofiles=$(find "$fld" -name *.ISO)
  fi

  if [[ $isofiles != "" ]]; then 
    for iso in $isofiles
    do
      output=$(dirname "${iso}")

      7z x "$iso" -oc:"$output/"

      if [[ $? -eq 0 ]]; then
        rm $iso
      fi
    done     
  fi
done