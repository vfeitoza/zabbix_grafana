#!/bin/bash

file=/tmp/$3

[ $# -eq 0 ] && { echo "Usage: $0 filename"; exit 1; }
[ ! -f "$file" ] && { whois as$(snmpwalk -v2c -c $1 $2 iso.3.6.1.4.1.2011.5.25.177.1.1.2.1.2.0.1.1.1.4.$3 | awk {'print $4'}) | grep -i owner: | awk '{$1=""; print $0}' > /tmp/$3 ; cat $file; exit 0;}
 
if [ -s "$file" ] 
then
        cat $file
else
        whois as$(snmpwalk -v2c -c $1 $2 iso.3.6.1.4.1.2011.5.25.177.1.1.2.1.2.0.1.1.1.4.$3 | awk {'print $4'}) | grep -i owner: | awk '{$1=""; print $0}' > /tmp/$3
        cat $file
