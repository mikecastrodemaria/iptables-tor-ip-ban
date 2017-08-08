#!/bin/bash
# iptables_ban_tor.sh

#  this script download Ip list from check.torproject.org
#+ using your configured ip
#  replace MYIP value by your own IP
#  replace SETNAME value by your own iptable chaine name
#  use iptable and logger

SETNAME="tor_ips"
MYIP="192.168.0.100"
MYPORT="80"

#
iptables -X $SETNAME
iptables -N $SETNAME

DAY=$(date -d "1 hours ago" | awk '{print $2" "$3" "$4}' | cut -d ":" -f1)
IP=$( curl "https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=${MYIP}&port=${MYPORT}" 2>/dev/null | tail -n +4 )

if [ -n "$IP" ]; then # only proceed if new IPs are obtained
        /sbin/iptables -F $SETNAME
        logger -t "tor_ip_block" "Fluch iptables chain $SETNAME ."
        for ipliste in $IP
                do
                        /sbin/iptables -A $SETNAME -s $ipliste -j REJECT
                        #echo "suppression de l'IP:" $ipliste
                        logger -t "tor_ip_block" "Add iptables rules for ip $ipliste using chain $SETNAME ."
                done
else
        logger -t "tor_ip_block" "No IPs to add."
fi
exit 0
