#!/bin/sh
N=$1
while read LINE; do
  if test "$N" = "0"; then
    echo "$LINE"
  else
    N=$(($N-1));
  fi
done