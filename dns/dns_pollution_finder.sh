#! /bin/sh
#
# dns_pollution_finder.sh
# Copyright (C) 2023 StrayWarrior <i@straywarrior.com>
#
# Distributed under terms of the MIT license.
#

dns_china=114.114.114.114
dns_outside=8.8.8.8

while read -r line; do
    domain=$(echo $line | awk '{ print $1 }')
    dns_answer_china=$(dig +short @$dns_china $domain |tail -n 1)
    dns_answer_outside=$(dig +short @$dns_outside $domain |tail -n 1)
    if [ "$dns_answer_china" != "$dns_answer_outside" ]; then
        echo "$domain \t $dns_answer_china\t$dns_answer_outside"
    else
    	echo "$domain \t ..... OK" 
    fi
done < domains.txt
