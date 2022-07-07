#!/bin/bash

# When calling the script you have to transfer the interface name. 
# Example: bash linkRxTx.sh eth0

rxQuery() {
    ifname=$1
    echo $(cat /proc/net/dev | grep $ifname | sed 's/:/ /g' | awk '{print $2}')
}

txQuery() {
    ifname=$1
    echo $(cat /proc/net/dev | grep $ifname | sed 's/:/ /g' | awk '{print $10}')
}

printFormatUnit() {
    value=$1
    if [[ $value -lt 1024 ]]; then
        value="${value}  B/s"
    elif [[ $value -gt 1048576 ]]; then
        value=$(roundValue $(echo $value | awk '{print $1/1048576}'))
        value="${value} MB/s"
    else
        value=$(roundValue $(echo $value | awk '{print $1/1024}'))
        value="${value} KB/s"
    fi
    echo $value
}

roundValue() {
    echo $(LC_ALL=C /usr/bin/printf "%.*f\n" "3" "$1")
}

ifname=$1

# Here you can change the query interval: 
interval=5

clear
echo "I start the query. In $interval seconds you will get the first values."

while true; do
    rx_pre=$(rxQuery $ifname)
    tx_pre=$(txQuery $ifname)

    sleep $interval

    rx_next=$(rxQuery $ifname)
    tx_next=$(txQuery $ifname)

    clear

    echo "Query interval $interval seconds"
    printf "%-10s %-10s %14s %14s \n" "time" "ip link" "rx" "tx"
    rx=$(((${rx_next} - ${rx_pre}) / $interval))
    tx=$(((${tx_next} - ${tx_pre}) / $interval))

    rx=$(printFormatUnit $rx)
    tx=$(printFormatUnit $tx)

    printf "%-10s %-10s %14s %14s \n" "$(date +%k:%M:%S)" "$ifname" "$rx" "$tx"
done
