#!/bin/bash

# When calling the script you have to pass the interface name
# and optionally the name of the file for output as csv file.
# Example: bash iftraffic.sh eth0
# or: bash iftraffic.sh eth0 link.csv

# Variable is given when the script is called.
ifname=$1

# Here you can change the query interval:
interval=5
periods=(1 2 6 12)
# Specify the name of the output csv file here:
# csvFileName="csv.out" or so
csvFileName=$2

test_args() {
    RED='\033[0;31m'
    YEL='\033[0;33m'
    NC='\033[0m'
    if [ ! -n "$1" ]; then
        # If no arguments are given, the following information is output and the script is terminated.
        echo -e "${RED}Arguments are missing.${NC}"
        printUsage
        return 1
    fi
    for ifname in $(ls /sys/class/net); do
        if [[ "$ifname" == "$1" ]]; then
            return 0
        fi
    done
    # If the specified interface does not exist, it continues here and the script is then terminated.
    echo -e "There is no interface with the name ${RED}$1${NC}."
    echo "This computer has the following interfaces:"
    for ifname in $(ls /sys/class/net); do
        echo -e ${YEL}$ifname${NC}
    done
    printUsage
    return 1
}

roundValue() {
    value=$1
    echo $(LC_ALL=C /usr/bin/printf "%.*f\n" "2" "$value")
}

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

makeCSVfile() {
    # "$(date +%s%N),$ifname,$(($interval * $intervalFactor)),$rx,$tx" >>$csvFileName
    echo "timestamp,iface,interval,RX,TX" >$1
}

printUsage() {
    echo "${0##*/} - displays the amount of received and transmitted data for the selected network interface"
    printf " Usage:   %15s interface [csv-file_name] \n" $(basename $0)
    printf " example: %15s eth0 \n" $(basename $0)
}

main() {
    ifname=$1
    interval=$2
    periods=$3
    csvFileName=$4

    # Create a new file for the csv formatted results.
    if [ ! -z "$4" ]; then
        makeCSVfile $csvFileName
    fi

    # Prepare output in terminal
    clear
    echo "I start the query. In $(($interval * ${periods[0]})) seconds you will get the first values."
    sleep 1

    while true; do
        # Read values and store them in array
        rx_+=($(rxQuery $ifname))
        tx_+=($(txQuery $ifname))

        # Wait defined interval (5 seconds)
        sleep $interval

        # Read values and store them in array
        rx_+=($(rxQuery $ifname))
        tx_+=($(txQuery $ifname))

        # Output to terminal (stdout)
        # Clean terminal and print headers
        clear
        echo "time: $(date +%k:%M:%S)  --> ip link: $ifname"
        # echo "Query interval $interval seconds"
        printf "%7s %14s %14s \n" "average" "rx" "tx"

        # Calculate the average values for the periods

        # Number of values in array: {#rx_[@]}
        # the last value in the array: {rx_[-1]}

        for period in "${periods[@]}"; do # $periods
            intervalFactor=$period
            if [ ${#rx_[@]} -ge $((intervalFactor + 1)) ]; then
                rx=$(((${rx_[-1]} - ${rx_[$((${#rx_[@]} - ($intervalFactor + 1)))]}) / ($interval * $intervalFactor)))
                tx=$(((${tx_[-1]} - ${tx_[$((${#tx_[@]} - ($intervalFactor + 1)))]}) / ($interval * $intervalFactor)))
                # prints to csv file
                if [ ! -z "$4" ]; then
                    echo "$(date +%s),$ifname,$(($interval * $intervalFactor)),$rx,$tx" >>$csvFileName
                fi
                # prints formatted to terminal / stdout
                rx=$(printFormatUnit $rx)
                tx=$(printFormatUnit $tx)
                printf "%7s %14s %14s \n" "$(($interval * $intervalFactor)) s" "$rx" "$tx"
            fi
        done

        # I remove the last values from the arrey, because they will be reset on the next loop pass.
        unset 'rx_[-1]'
        unset 'tx_[-1]'

        # delete the oldest value in the array
        # when all values of the longest period have been saved
        if [ ${#rx_[@]} -ge $((intervalFactor + 1)) ]; then
            rx_=("${rx_[@]:1}")
            tx_=("${tx_[@]:1}")
        fi
    done
}

# First I test if the specified interface exists, if the test was successful
# I start the main program and put in the variables ifname and interval.

test_args $ifname && main $ifname $interval $periods $csvFileName
