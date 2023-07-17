#!/bin/bash

################################################################################
##
##  nic_stats.sh
##
##             - a simple cron script to write out nic stats over time.
##
##  Usage:     This runs from an interactive shell, but you can background it.
##             Adjust variables below before running, especially INTERVAL.
##
##  MAINTAINER:  jeder@redhat.com
##
##
################################################################################

################################################################################
##  Define Global Variables and Functions


HOSTNAME=`uname -n`
DATE=`date "+%m-%d"`
LOGDIR=/tmp/nic_stats_${DATE}
INTERVAL=10
INTERFACES="eth0 eth1 eth2 eth3"
ETHTOOL_CMDS="-S -g"
TC_CMD=" -s qdisc show dev "


################################################################################
##  Main Program

if [ ! -d $LOGDIR ]; then mkdir -p $LOGDIR ; fi

while /bin/true ; do
	for iface in $INTERFACES ; do
		echo $iface
		for etool in $ETHTOOL_CMDS ; do
		echo $etool
		echo	ethtool $etool $iface | awk '{print "$iface.ethtool-i$etool",strftime("%c"),$0}'
		done
done


	ethtool -S eth0 |awk '{print "eth0.ethtool-s",strftime("%c"),$0}'
	ethtool -S eth1 |awk '{print "eth1.ethtool-s",strftime("%c"),$0}'
	ethtool -S eth2 |awk '{print "eth2.ethtool-s",strftime("%c"),$0}'
	ethtool -S eth3 |awk '{print "eth3.ethtool-s",strftime("%c"),$0}'
	ethtool -g eth0 |awk '{print "eth0.ethtool-g",strftime("%c"),$0}'
	ethtool -g eth1 |awk '{print "eth1.ethtool-g",strftime("%c"),$0}'
	ethtool -g eth2 |awk '{print "eth2.ethtool-g",strftime("%c"),$0}'
	ethtool -g eth3 |awk '{print "eth3.ethtool-g",strftime("%c"),$0}'

	tc -s qdisc show dev eth0 | awk '{print "eth0.tc",strftime("%c"),$0}'
	tc -s qdisc show dev eth1 | awk '{print "eth1.tc",strftime("%c"),$0}'

	cat /proc/net/snmp | awk '{print "procnetsnmp",strftime("%c"),$0}'
	cat /proc/net/dev | awk '{print "procnetdev",strftime("%c"),$0}'
	cat /proc/net/softnet_stat | awk '{print "procnetsoftnet_stat",strftime("%c"),$0}'

	sleep ${INTERVAL}

done > ${LOGDIR}/${HOSTNAME}.nic_stats.${DATE}
