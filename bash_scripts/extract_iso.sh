#!/bin/bash

for fld in "$@"
do
  iso=$(find "$fld" -name *.iso)

  if [[ $iso == "" ]]; then
    iso=$(find "$fld" -name *.ISO)
  fi

  if [[ $iso != "" ]]; then 
    output=$(dirname "${iso}")

    7z x "$iso" -oc:"$output/"

    if [[ $? -eq 0 ]]; then
      rm $iso
    fi    
  fi
done