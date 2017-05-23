#!/bin/bash

# == TODOs ==           [-] undone          [+] implemented
#
# [+] disconnect all
# [+] lo issue to file
        # server
        # timestamp
# [+] wait 30 sec to allow myself cancel manual shit
#       OR
# [+] proceed with ENTER manually
# [+] block iptables ports 80 and 443 to avoid automatic requests
# [+] reconnect wlan1
# [+] connect to vpn
# [+] check vpn is working
# [+] allow 80 and 443 back
# [+] ports array
# [-] nw interfaces array



#######################
# Variable declaration
#######################
FLAG_VPN=1
PORTS_BLOCK=( 80 443 )
DISCONNECT_TIME=""
VPN_SERVER=""


#######################
# Functions declaration
#######################
check_vpn_connected() {
    CHECK=$(expressvpn status | awk '{print $1}')

    if [ $CHECK == "Connected" ]; then
        VPN_SERVER=$(expressvpn status | cut -d' ' -f3-)
        echo "[+] Connected to: " $VPN_SERVER " -- " $(date)
    else
        echo ""
        echo "[!] Careful! VPN lost!!"
        echo ""
        DISCONNECT_TIME=$(date)
        shut_down_connections
        FLAG_VPN=0
    fi
    sleep 1
}

shut_down_connections() {
    echo "[+] Disconnecting..."
     nmcli dev disconnect wlan1
     nmcli dev disconnect wlan0
     nmcli dev disconnect eth0
    echo "[+] Done"
}

blocking_http_https() {
    echo "[+] Proceding to block all traffic through key ports (user provided)"

    for p in "${PORTS_BLOCK[@]}"
    do
        echo "[+] Blocking port $p"
        /sbin/iptables -A OUTPUT -p tcp --dport $p -j DROP
    done
}

restablish_nw_i() {
    echo "[+] Restablishing network interfaces"
     nmcli dev connect wlan1
     nmcli dev connect wlan0
     nmcli dev connect eth0
    echo "[+] Done"
}

count_down_for_user_reaction() {
    echo "[+] Allowing user time to manually cancel other outgoing traffic"
    secs=$((1 * 30))
    while [ $secs -gt 0 ]; do
       echo -ne "$secs\033[0K\r"
       sleep 1
       : $((secs--))
    done
    echo "[+] Done"
}

press_enter_to_continue() {
    read -rsn1 -p"Press any key to continue";echo
}

reconnect_vpn() {
    echo "[+] Reconnecting to VPN service"
    sleep 7  # to allow proper reconnection to interface. Avoid early error
    expressvpn connect

    CHECK=$(expressvpn status | awk '{print $1}')
    if [ $CHECK == "Connected" ]; then
        VPN=$(expressvpn status | cut -d' ' -f3-)
        echo "[+] Connected to: " $VPN_SERVER " -- " $(date)
    else
        echo ""
        echo "[!] Was not possible to reconnect to the VPN"
        echo "[!] Iptables are still blocking ports 80 and 443 as security measure"
        echo "[!] If you want to h iptables just issue 'iptables --flush'"
        echo "[!] Exiting..."
        exit
    fi
}

flush_iptables() {
    echo "[+] Flushing iptables..."
    for p in "${PORTS_BLOCK[@]}"
    do
        echo "[+] Blocking port $p"
        /sbin/iptables -D OUTPUT -p tcp --dport $p -j DROP
    done
    echo "[+] Done"
    FLAG_VPN=1
}

log() {
    # Create day log file
    if [ ! -f $(date +"%d-%m-%Y").log ]; then
        touch $(date +"%d-%m-%Y").log
    fi
    echo $DISCONNECT_TIME -- $VPN_SERVER >> $(date +"%d-%m-%Y").log
}


#######################
# Script
#######################
while true
do
    while [ $FLAG_VPN -eq 1 ]
    do
        check_vpn_connected
    done

    blocking_http_https
    # count_down_for_user_reaction  # activate this and specify time for auto reconnect
                                    # and then comment out press_enter_to_continue
    press_enter_to_continue
    restablish_nw_i
    reconnect_vpn
    flush_iptables
    log
done
