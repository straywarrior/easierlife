#!/bin/sh -e

HOSTNAME=""
PASSWORD=""

logging_info() {
    time=`date +"%Y-%m-%d %H:%M:%S"`
    echo "[$time]" $*
}

my_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
current_a_record=$(dig +short $HOSTNAME @114.114.114.114)
if [ "$my_ip" != "$current_a_record" ]; then
    logging_info "ip changed, current[$current_a_record], next[$my_ip], update record..."
    curl "https://dyn.dns.he.net/nic/update" -d "hostname=$HOSTNAME" -d "password=$PASSWORD" -d "myip=$my_ip"
else
    logging_info "ip not changed, skip update."
fi
