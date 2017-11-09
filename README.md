# Traffic-watch

Traffic-watch is a bash script that could helps you to deal with the daily traffic limitation management. It is helpful especially on headless machines because almost all similar applications are designed to work with GUI. It is designed for Ubuntu 16.04 or later and uses the command `ifconfig`.

The sctip is inspired by the question [Daily Download Lmit?](https://askubuntu.com/questions/963522/daily-download-limit) of [AskUbuntu.com](https://askubuntu.com/).

The script will get the data of incoming and outgoing traffic from `ifconfig interface-name` and will compare the sum with a predefined limit value. This action will be repeated every 5 seconds (for example). 

When the amount of the traffic (income+outcome) becomes equal or greater than the limit, the script will disable the target interface and exit. The maximum discrepancy between the actual value at which the interface will be disabled and the limit value will be equal to `5s` x `MaxSpeed`.

The script can be executed by Cron job. So you will be able to set different job for each day of the week, etc. Additionally when the limit is reached you can run the script manually with an additional amount of traffic.

The script name should be **`traffic-watch`**, otherwise you should change its 5th line. My suggestion is to place (or symlink) it in `/usr/local/bin`, thus it will be available as shell command. Don't forget to make it executable. There is also an interactive installator **`install.bash`**.
      
The script should be executed as root (`sudo`). It creates a log file: `/tmp/traffic-watch-interface-name.log`, where you can check the last action. The script has two input variables:

- `$1`=`$LIMIT` - the value of the traffic limit in MB - the default value is `400`.
- `$2`=`$IFACE` - the name of the target network interface - the default value is `eth0`.
- If you want to override these values during the execution of the script, use these formats:

      traffic-watch "250" "enp0s25"
      traffic-watch "250"
      traffic-watch "" "enp0s25"

## Use 'traffic-watch' with 'crontab'

If you want to run the script every morning at `6:30`, open root's Crontab (`sudo crontab -e`) and add this line:

    30 6 * * * /usr/local/bin/traffic-watch 2>/dev/null

## Use 'traffic-watch' manually 

To run the script as root and push it into the background we shall use <a href="https://askubuntu.com/q/750419/566421">`sudo -b`<a>:

    sudo -b traffic-watch "150" 2>/dev/null
    
## Notes

- **Disable the script when you update and upgrade the system! The lack of internet could be cause of broken packages.**

- It is a good idea to attempt to kill the previous instance of the script (just in case its limit is not reached) before run a new:

    <!-- language: bash -->

      sudo pkill traffic-watch
      sudo -b traffic-watch "150" 2>/dev/null &

    <!-- language: bash -->

      29 6 * * * /usr/bin/pkill traffic-watch 2>/dev/null 
      30 6 * * * /usr/local/bin/traffic-watch 2>/dev/null 

- Probably `2>/dev/null` is not obligatory, because, I think all, errors are redirected to `/dev/null` by the script itself.

- To check the remaining traffic remotely you can use this command:

      ssh user@host.or.ip tail -n3 /tmp/traffic-watch-eth0.log

   *Replace `eth0` with the actual interface in use.*

- To get back your network interface UP: First ise `ifconfig -a` to find its name. Then `sudo ifconfig INTERFACE up`.

- This script could be recreated to work with `iptables` instead of`ifconfig - up/down`. 
**This will be a powerful solution**.

## References

- [How to reset ifconfig counters?](https://askubuntu.com/questions/348038/how-to-reset-ifconfig-counters)
- [How to execute script when network interface is up?](https://askubuntu.com/questions/277284/execute-script-when-network-interface-is-up)
- [More about the calculations](https://unix.stackexchange.com/a/40787/201297)
- [How to get TX/RX bytes without `ifconfig`](https://serverfault.com/questions/533513/how-to-get-tx-rx-bytes-without-ifconfig)
- [The connected project `traffic-get`](https://github.com/pa4080/traffic-get)
