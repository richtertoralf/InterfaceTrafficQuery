# iftraffic
Linux Bash script to query interface traffic directly from /proc/net/dev

![Screenshot](https://github.com/richtertoralf/InterfaceTrafficQuery/blob/93c94a36c46bf20e6650362c176b52b50ef7af52/Screenshot_linkRxTxV2.png "linkRxTxV2.sh")

*tested with Linux Ubuntu 20.04*  

With this script you can display the traffic on the interfaces of your computer. For example on eth0, wlan0, enp0s3 and so on.
You should know the interface names of your computer or just show them with `ip link show`.
The script fetches the transferred bytes in intervals of e.g. five seconds directly from /proc/net/dev of the corresponding interface with the following commands:  
- cat /proc/net/dev | grep $ifname | sed 's/:/ /g' | awk '{print $2}'  
- cat /proc/net/dev | grep $ifname | sed 's/:/ /g' | awk '{print $10}'  

```
~/InterfaceTrafficQuery$ bash iftraffic.sh -h
Usage: iftraffic.sh 
    [ -h | --help ] -> show this help message and exit
    [ -q | --quiet] -> no output of information in terminal
    [ -i | --ifname name] -> Specification of the interface name.
    [ -n | --interval sec ] -> Specification of the query interval in seconds. The default value is 5 seconds.
    [ -p | --periods sec ] -> Specify the periods as a factor to the interval. Default is "1 3 6 12".
    [ -c | --csv filename] -> Specify the name of the output file for output in csv format."
examples:
iftraffic.sh -i eth0
iftraffic.sh -i wlan0 -csv mytraffic.csv
iftraffic.sh -i enp0s3 -n 5 -p 2 -csv traffic.csv -q
iftraffic.sh -i enp0s3 -n 1 -p "1 5 30" --csv mytraffic.csv
```

Example of output when calling the script specifying a non-existent interface:
```
$ bash iftraffic.sh -i eth0
There is no interface with the name eth0.
This computer has the following interfaces:
enp0s3
lo
```
## Download with:  
`git clone https://github.com/richtertoralf/InterfaceTrafficQuery` 
## Start with:
`cd InterfaceTrafficQuery`  
`bash iftraffic.sh -i eth0` or `bash iftraffic.sh -i eth0 --csv out.csv`  
