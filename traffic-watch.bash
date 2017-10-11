#!/bin/bash

# Initialize
[ -z "${1}" ] && LIMIT="400"  || LIMIT="$1" # Set the total traffic daily limit in MB
[ -z "${2}" ] && IFACE="eth0" || IFACE="$2" # Set the name of the target interface
LOG="/tmp/traffic-watch-$IFACE.log"         # Set the log file name
LANG=C                                      # Set envvar $LANG to `C` due to grep, awk, etc.
IPPT='[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'       # Set IP address match pattern #IPPT='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'

NIC="$(/sbin/ethtool -i "$IFACE" | awk 'FS=": " {print $2; exit}')" # Get the $IFACE (NIC) driver

# Function: Get the current traffic
get_traffic(){
    RX="$(/sbin/ifconfig "$IFACE" | grep -Po "RX bytes:[0-9]+" | sed 's/RX bytes://')" # Get the incoming traffic
    TX="$(/sbin/ifconfig "$IFACE" | grep -Po "TX bytes:[0-9]+" | sed 's/TX bytes://')" # Get the outgoing traffic
    XB=$(( RX + TX ))                                                            # Calculate the total traffic
    XM=$(( XB / ( 1000 * 1000 ) ))                                               # Convert the total traffic in MB
}

# Functions: Disable the interface
interface_down(){ /sbin/ifconfig "$IFACE" down 2>/dev/null && exit; }

# Function: Reset the traffic and enable the interface
reset_traffic_interface_up(){ /sbin/modprobe -r "$NIC" 2>/dev/null && /sbin/modprobe "$NIC" 2>/dev/null && /sbin/ifconfig "$IFACE" up 2>/dev/null; }

# Function: Get the IP address
get_ip(){ /sbin/ifconfig "$IFACE" 2>/dev/null | grep -Po "${IPPT}" | head -1; }

# --- The main program ---

reset_traffic_interface_up

# Wait until the IP address is obtained
until [[ "$(get_ip)" =~ ${IPPT} ]]; do sleep 1; done

# While the interface has IP address == while it is up; check if it is up on every 5 seconds (the `time` of the cycle is about 75 ms)
while [[ "$(get_ip)" =~ ${IPPT} ]]; do

    get_traffic

    # Start logging
    printf '\n%s\n\nI-face:\t%s\nDriver:\t%s\nIP:\t%s\n' "$(date)" "$IFACE" "$NIC" "$(get_ip)" > "$LOG"
    printf '\nRX:\t%s\nTX:\t%s\nXB:\t%s\nXM:\t%s\n' "$RX" "$TX" "$XB" "$XM" >> "$LOG"

    if (( XM >= LIMIT )); then
        printf '\nThe daily limit of %s MB was reached.' "$LIMIT" >> "$LOG"
        printf '  The interface %s was disabled!\n\n' "$IFACE" >> "$LOG"
        interface_down
    else
            printf '\n%s MB remains on %s.\n\n' "$(( LIMIT - XM ))" "$IFACE" >> "$LOG"
    fi

    # Debug:    cat "$LOG"

    sleep 5 ## *Adjust this value* ##

done; interface_down
