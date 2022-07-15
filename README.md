# iftraffic
Linux Bash script to query interface traffic directly from /proc/net/dev

![Screenshot](https://github.com/richtertoralf/InterfaceTrafficQuery/blob/93c94a36c46bf20e6650362c176b52b50ef7af52/Screenshot_linkRxTxV2.png "linkRxTxV2.sh")

*tested with Linux Ubuntu 20.04*  

With this script you can display the traffic on the interfaces of your computer. For example on eth0, wlan0, enp0s3 and so on.
You should know the interface names of your computer or just show them with `ip link show`.
The script fetches the transferred bytes in intervals of e.g. five seconds directly from /proc/net/dev of the corresponding interface with the following commands:  
- cat /proc/net/dev | grep $ifname | sed 's/:/ /g' | awk '{print $2}'  
- cat /proc/net/dev | grep $ifname | sed 's/:/ /g' | awk '{print $10}'  

Have a look at the source code before you start the script!  
When calling the script you have to transfer the interface name.  
Example 1: `bash iftraffic.sh eth0`  
Example 2: `bash iftraffic.sh wlan0 myoutputfile.csv`

Example of output when calling the script specifying a non-existent interface:
```
$ bash iftraffic.sh eth0
There is no interface with the name eth0.
This computer has the following interfaces:
enp0s3
lo
```
## Download with:  
`git clone https://github.com/richtertoralf/InterfaceTrafficQuery` 
## Start with:
`cd InterfaceTrafficQuery`  
`bash iftraffic.sh eth0` or `bash iftraffic.sh eth0 out.csv`  
## next steps
The following will be implemented shortly, as script with `getopt`:
```
            [ -h | --help ] -> show this help message and exit
            [ -q | --quiet] -> no output of information in terminal
            [ -i | --ifname name] -> Specification of the interface name.
            [ -n | --interval sec ] -> Specification of the query interval in seconds. The default value is 5 seconds.
            [ -p | --periods sec ] -> Specify the periods as a factor to the interval. 
            [ -c | --csv filename] -> Specify the name of the output file for output in csv format."
```
Currently you still have to make the settings for the as query interval and the periods in the source code. 
```
# Here you can change the query interval:
interval=5
periods=(1 2 3 6 12 120)
```
With the above in the source code, you get the following output:
```
$ bash iftraffic.sh enp0s3
time: 12:46:11  --> ip link: enp0s3
average             rx             tx 
    5 s        208 B/s        242 B/s 
   10 s        221 B/s        326 B/s 
   15 s        217 B/s        340 B/s 
   30 s        221 B/s        368 B/s 
   60 s        226 B/s        389 B/s 
  600 s        228 B/s        401 B/s 
```
