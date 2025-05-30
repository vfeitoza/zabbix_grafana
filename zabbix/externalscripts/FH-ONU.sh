#!/bin/bash

walk=/var/tmp/walk-$2

if [ $1 = "check" ]; then
        snmpbulkwalk -v2c -c adsl $2 .1.3.6.1.4.1.5875.800.3.10.1.1.11 > $walk &
        echo "CHECK!"
        exit
fi

if [ $1 = "on" ]; then
        cat $walk | grep 1$ | wc -l
        exit
fi

if [ $1 = "off" ]; then
        cat $walk | grep 0$ | wc -l
        exit
fi

if [ $1 = "desativada" ]; then
        cat $walk | grep 2$ | wc -l
        exit
fi

if [ $1 = "total" ]; then
        cat $walk | wc -l
        exit
fi
