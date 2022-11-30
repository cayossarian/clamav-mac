#!/bin/bash

# Maintainer : cayossariano
# Script "ClamAV real time", by coldnfire, cayossarian
# Dependency : fswatch, postfix
 
logfile="/var/log/clamav/clamav_tr_$(date +'%Y-%m-%d').log";
mac=$(ifconfig en0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}');
folder=/Users/bflood/Users/bflood
user=bfloodbflood
jail=/var/jail/var/jail
email=bill@ipheart.combill.flood@me.com

/opt/homebrew/bin/freshclam
/opt/homebrew/sbin/clamd
postfix start
 
while :
do
 
fswatch -l 1 $folder |
while read file; do
	/opt/homebrew/bin/clamdscan -m -v --fdpass "$file" --move=$jail
        if [ "$?" == "1" ]; then
		echo -e "Malware found!!!" "File '$file' file has been moved to jail !" >> $logfile
		echo -e "Malware found" "File '$file' has been moved to jail, the user is $user with mac address $mac the result of the scan is in $logfile" | mail -s "$user $mac" $email
        fi
	done
done
