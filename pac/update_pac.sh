#!/bin/bash -e

LIST_URL="https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt"
PROXY="socks5://127.0.0.1:1083"
TEMPLATE_IN=$1
OUTPUT_NAME=$2

if [ -z "$TEMPLATE_IN" ]; then
    echo "TEMPLATE_IN is not defined"
    exit 1
fi

if [ -z "$OUTPUT_NAME" ]; then
    echo "OUTPUT_NAME is not defined"
    exit 1
fi

rand_str=$(echo $RANDOM |md5sum |head -c 8)
temp_filename="/tmp/pac.${rand_str}.temp"

ALL_PROXY=$PROXY curl $LIST_URL \
    |base64 -d \
    |grep -E "(^\|)|(^\.)|(^[a-z])" \
    |sed 's/^/  "/' \
    |sed 's/$/",/' > $temp_filename

echo "upstream rules saved to temporary file: $temp_filename"
echo "update $OUTPUT_NAME with template: $TEMPLATE_IN"

sed "/UPSTREAM_RULES_CONTENT/r$temp_filename" $TEMPLATE_IN \
    |sed "/UPSTREAM_RULES_CONTENT/d" \
    |tr -d "\r" > $OUTPUT_NAME
rm $temp_filename
