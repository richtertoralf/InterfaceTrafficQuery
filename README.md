# InterfaceTrafficQuery
Linux Bash script to query interface traffic directly from /proc/net/dev

![Screenshot](https://github.com/richtertoralf/InterfaceTrafficQuery/blob/4594f2cf42f402e449ada16f65874303bd5ddfa8/Screenshot_linkRxTx.png)

*tested with Linux Ubuntu 20.04*  
With this script you can display the traffic on the interfaces of your computer. For example on eth0, wlan0, enp0s3 and so on.
You should know the interface names of your computer or just show them with `ip link show`.
The script fetches the transferred bytes in intervals of e.g. five seconds directly from /proc/net/dev of the corresponding interface with the following commands:  
- cat /proc/net/dev | grep $ifname | sed 's/:/ /g' | awk '{print $2}'  
- cat /proc/net/dev | grep $ifname | sed 's/:/ /g' | awk '{print $10}'  

Have a look at the source code before you start the script!  
When calling the script you have to transfer the interface name.  
Example: bash ethRxTx.sh eth0

Example of script call:
```
$ bash linkRxTx.sh eth0
There is no interface with the name eth0.
This computer has the following interfaces:
enp0s3
lo
```
## Download with:  
`git clone https://github.com/richtertoralf/InterfaceTrafficQuery` 
## Start with:
`cd InterfaceTrafficQuery`  
`bash linkRxTx.sh eth0`  
