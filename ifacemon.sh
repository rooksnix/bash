#!/bin/bash
#
# ifacemon.sh - script to capture networking related data
# to debug packet issues at NIC/NIC driver levels.
# Author: Flavio Leitner <fbl@redhat.com>
# Version: v1.0
# http://people.redhat.com/~fleitner/ifacemon/

if [ -z "$1" ]; then
	echo "usage: $0 <iface>"
	exit 1
fi

echo "Monitoring interface $1"
echo "Please, reproduce the issue"
echo "To stop the script, hit CTRL+C"

IFACE="$1"
INTERVAL=2
OUTPUT="/tmp/$IFACE"
if [ ! -d $OUTPUT ]; then
  mkdir -p $OUTPUT
fi

ethtool -k $IFACE > $OUTPUT/ethtool-k.log
ethtool -g $IFACE > $OUTPUT/ethtool-g.log
ethtool -i $IFACE > $OUTPUT/ethtool-i.log
ethtool -a $IFACE > $OUTPUT/ethtool-a.log
ethtool $IFACE > $OUTPUT/ethtool.log

while :;
do
  echo -n "."
  TIMESTAMP=`date`
  echo "$TIMESTAMP" >> $OUTPUT/mpstat.log
  mpstat -P ALL >> $OUTPUT/mpstat.log

  echo "$TIMESTAMP" >> $OUTPUT/sar-dev.log
  sar -n DEV 0 >> $OUTPUT/sar-dev.log

  echo "$TIMESTAMP" >> $OUTPUT/sar-edev.log
  sar -n EDEV 0 >> $OUTPUT/sar-edev.log

  echo "$TIMESTAMP" >> $OUTPUT/tc-s.log
  tc -s class show dev $IFACE >> $OUTPUT/tc-s-class.log

  echo "$TIMESTAMP" >> $OUTPUT/tc-s.log
  tc -s qdisc show dev $IFACE >> $OUTPUT/tc-s-qdisc.log

  echo "$TIMESTAMP" >> $OUTPUT/proc.interrupts.log
  cat /proc/interrupts >> $OUTPUT/proc.interrupts.log

  echo "$TIMESTAMP" >> $OUTPUT/proc.softirqs.log
  cat /proc/softirqs >> $OUTPUT/proc.softirqs.log

  echo "$TIMESTAMP" >> $OUTPUT/ethtool-S.log
  ethtool -S $IFACE >> $OUTPUT/ethtool-S.log

  echo "$TIMESTAMP" >> $OUTPUT/netstat-s.log
  netstat -s >> $OUTPUT/netstat-s.log
  sleep $INTERVAL
done
