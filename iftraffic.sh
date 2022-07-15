#!/bin/bash
# Set some default values:
quiet=false
if_name=unset
csv_file=unset
query_interval=5
periods=(1 3 6 12)

# echo "args:" $@
# echo "\$1:" $1

RED='\033[0;31m'
YEL='\033[0;33m'
NC='\033[0m'

usage() {
    echo "Usage: $0 
            [ -h | --help ] -> show this help message and exit
            [ -q | --quiet] -> no output of information in terminal
            [ -i | --ifname name] -> Specification of the interface name.
            [ -n | --interval sec ] -> Specification of the query interval in seconds. The default value is 5 seconds.
            [ -p | --periods sec ] -> Specify the periods as a factor to the interval. 
            [ -c | --csv filename] -> Specify the name of the output file for output in csv format."
    echo "example 1: $0 -i eth0"
    echo "example 2: $0 -i wlan0 -csv mytraffic.csv"
    echo "example 3: $0 -i enp0s3 -n 1 -p "5" --csv mytraffic.csv"
    exit 1
}

test_ifname() {
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
    usage
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

main() {
    ifname=$1
    interval=$2
    periods=$3
    csvFileName=$4
    quiet=$5

    # Create a new file for the csv formatted results.
    if ! [ "$csvFileName" = "unset" ]; then
        makeCSVfile $csvFileName
    fi

    # Prepare output in terminal
    if ! [ "$quiet" = true ]; then
        clear
        echo "I start the query. In $(($interval * ${periods[0]})) seconds you will get the first values."
        sleep 1
    fi
    while true; do
        # Read values and store them in array
        rx_+=($(rxQuery $ifname))
        tx_+=($(txQuery $ifname))

        # Wait defined interval (5 seconds)
        sleep $interval

        # Read values and store them in array
        rx_+=($(rxQuery $ifname))
        tx_+=($(txQuery $ifname))

        if ! [ "$quiet" = true ]; then
            # Output to terminal (stdout)
            # Clean terminal and print headers
            clear
            echo "time: $(date +%k:%M:%S)  --> ip link: $ifname"
            # echo "Query interval $interval seconds"
            printf "%7s %14s %14s \n" "average" "rx" "tx"
        fi
        # Calculate the average values for the periods

        # Number of values in array: {#rx_[@]}
        # the last value in the array: {rx_[-1]}

        for period in "${periods[@]}"; do # $periods
            intervalFactor=$period
            if [ ${#rx_[@]} -ge $((intervalFactor + 1)) ]; then
                rx=$(((${rx_[-1]} - ${rx_[$((${#rx_[@]} - ($intervalFactor + 1)))]}) / ($interval * $intervalFactor)))
                tx=$(((${tx_[-1]} - ${tx_[$((${#tx_[@]} - ($intervalFactor + 1)))]}) / ($interval * $intervalFactor)))
                # prints to csv file
                if ! [ "$csvFileName" = "unset" ]; then
                    echo "$(date +%s),$ifname,$(($interval * $intervalFactor)),$rx,$tx" >>$csvFileName
                fi
                if ! [ "$quiet" = true ]; then
                    # prints formatted to terminal / stdout
                    rx=$(printFormatUnit $rx)
                    tx=$(printFormatUnit $tx)
                    printf "%7s %14s %14s \n" "$(($interval * $intervalFactor)) s" "$rx" "$tx"
                fi
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

if [ $# = 0 ] || [[ ! $@ = *"-"* ]] || [[ $@ == "-" ]]; then
    echo -e "${RED}Arguments are missing.${NC}"
    usage
fi

# Option strings
SHORT='hqi:n:p:c:'
LONG='help,quiet,ifname:,interval:,periods:,csv:'

# read the options
OPTS=$(getopt -a -o $SHORT --long $LONG -n $0 -- "$@")

if [ $? != 0 ]; then
    echo "Terminating..." >&2
    usage
fi

eval set -- "$OPTS"

while true; do
    case "$1" in
    '-h' | '--help')
        # echo 'Option -h or --help'
        usage
        ;;
    '-q' | '--quiet')
        # echo 'Option -q or --quiet'
        quiet=true
        shift
        continue
        ;;
    '-i' | '--ifname')
        # echo 'Option -i or --ifname'
        if_name="$2"
        shift 2
        continue
        ;;
    '-n' | '--interval')
        # echo 'Option -n or --interval'
        query_interval=$2
        shift 2
        continue
        ;;
    '-p' | '--periods')
        # echo 'Option -p or --periods'
        periods=($2)
        # echo "new periods: ${periods[@]}"
        shift 2
        continue
        ;;
    '-c' | '--csv')
        # echo "Option -c or --csv, argument '$2'"
        csv_file="$2"
        shift 2
        continue
        ;;
    '--')
        # -- means the end of the arguments; drop this, and break out of the while loop
        shift
        break
        ;;
    *)
        echo " * Unexpected option: $1 , this should not happen."
        usage
        ;;
    esac
done

# echo "### Test: ###"
# echo "if_name : $if_name "
# echo "Query interval: $query_interval"
# echo "Periods as factor: ${periods[@]}"
# echo "csv_file: $csv_file"
# echo "quiet Mode: $quiet"
# read

test_ifname $if_name
main $if_name $query_interval $periods $csv_file $quiet
