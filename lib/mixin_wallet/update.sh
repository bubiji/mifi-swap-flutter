#!/usr/bin/env bash

STR=$1
DST=../$1

grep -Rn $STR | awk -F ':' '{print $1}' | uniq | while read F; do
sed -i "s@$STR@$DST@g" $F
done
