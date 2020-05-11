#!/bin/bash

for fld in "$@"
do
  srtfiles=$(find "$fld" -name *.srt)

  for f in $srtfiles; do
    mv -- "$f" "$(basename -- "$f" .srt).ro.srt"
  done
done