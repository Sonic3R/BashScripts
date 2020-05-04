#!/bin/bash

for fld in "$@"
do
  iso=$(find "$fld" -name *.iso)

  if [[ $iso == "" ]]; then
    iso=$(find "$fld" -name *.ISO)
  fi

  if [[ $iso != "" ]]; then 
    output=$(dirname "${fld}")

    7z x "$iso" -o "$output/"

    rm $iso
  fi
done