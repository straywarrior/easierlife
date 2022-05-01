#! /bin/sh
#
# ffmpeg_wrapper.sh
# Copyright (C) 2022 StrayWarrior <i@straywarrior.com>

output=$1
if [ "x$output" == "x" ]; then
    echo "[ERROR] no output specified."
fi

url=$(pbpaste |grep -E -o "'http.*'" |tr -d "'")
headers=$(pbpaste |grep "\-H " |grep -v "Host:" |sed -E 's/^.*-H '\''(.*)'\''.*$/\1/' |sed $'s/$/\\\r/g')
echo url: $url
echo headers:
echo "$headers"
read -p "confirm [y/N]: " invar
if [ "$invar" == "y" ]; then
    ffmpeg -icy 0 -headers "$headers" -i $url -c copy $output
fi

