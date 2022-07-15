#!/bin/bash
# Set some default values:
quiet=0
if_name=unset
csv_file=unset
query_interval=5
periods="1 3 6 12"

# echo "args:" $@
# echo "\$1:" $1

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
    exit 1
}

if [ $# = 0 ] || [[ ! $@ = *"-"* ]] || [[ $@ == "-" ]]; then
    echo "No arguments specified!"
    usage
fi

# Option strings
SHORT='hqi:n:p:c:'
LONG='help,quiet,ifname:,interval:,periods:,csv:'

# # read the options
OPTS=$(getopt -a -o $SHORT --long $LONG -n $0 -- "$@")

# if [ $? -ne 0 ]; then
#     echo 'Incorrect options provided. Terminating...'
#     usage
# fi

if [ $? != 0 ]; then
    echo "Terminating..." >&2
    usage
fi

# Note the quotes around "$OPTS": they are essential!

eval set -- "$OPTS"
# unset OPTS

while true; do
    case "$1" in
    '-h' | '--help')
        echo 'Option -h or --help'
        usage
        ;;
    '-q' | '--quiet')
        echo 'Option -q or --quiet'
        quiet=true
        shift
        continue
        ;;
    '-i' | '--ifname')
        echo 'Option -i or --ifname'
        if_name="$2"
        shift 2
        continue
        ;;
    '-n' | '--interval')
        echo 'Option -n or --interval'
        query_interval=$2
        shift 2
        continue
        ;;
    '-p' | '--periods')
        echo 'Option -p or --periods'
        periods=$2
        shift 2
        continue
        ;;
    '-c' | '--csv')
        echo "Option -c or --csv, argument '$2'"
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

echo "### Test: ###"
echo "if_name : $if_name "
echo "csv_file: $csv_file"
echo "Query interval: $query_interval"
echo "Periods as factor: $periods"
echo "quiet Mode: $quiet"
