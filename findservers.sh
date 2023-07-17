#!/bin/bash
#
# Copyright (c) 2010, Red Hat Inc.
# Permission to use, copy, modify, and/or distribute this software
# for any purpose with or without fee is hereby granted, provided that
# the above copyright notice and this permission notice appear in all copies.
#
# Takes a pcap network capture file in input and spits out
# a list of hosts that are running TCP servers. Currently
# this will only detect services for which a new connection
# was established at the time of the capture.
#
# Example:
#	./findservers.sh mycapture.pcap
#	10.242.35.90            mctp                  1100/tcp
#	10.242.35.90            pt2-discover          1101/tcp
#	10.242.35.90            adobeserver-1         1102/tcp
#	10.242.35.90            adobeserver-2         1103/tcp
#	10.242.35.90            ssh                   22/tcp
#	10.242.35.90            unassigned              23574/tcp
#	10.29.0.41              https                 443/tcp
#	10.29.0.41              http                  80/tcp www www-http
#	10.45.237.128           https                 443/tcp
#	10.46.96.12             unassigned              1028/tcp
#	10.46.96.12             epmap                 135/tcp
#	10.46.96.12             netbios-ssn           139/tcp
#	10.46.96.12             ldap                  389/tcp
#	10.46.96.12             microsoft-ds          445/tcp

# MAINTAINER: Pierre Carrier <prc@redhat.com>
# TODO: also handle connections for which we don't see the first packet
# TODO: fix columns alignment for unassigned ports

if [ -z $1 ] || [ ! -r $1 ]
then
	echo "$0: Cannot read input file: $1" >&2
	exit -1
fi

tcpdump -n -r $1 'tcp[tcpflags] & (tcp-syn) != 0 and tcp[tcpflags] & (tcp-ack) == 0' | \
awk '{  # $5 is something like this: 10.29.0.41.https:
	if (seen[$5] == 0) {
		split($5, server, /[:\.]/);
		printf("%d.%d.%d.%d\t%s\n",
		       server[1], server[2], server[3], server[4], server[5]);
		seen[$5]++;
	}
}' | while read HOST SERVICE
do
	SERVICEPORT=`getent services $SERVICE`
	if [ -z "$SERVICEPORT" ]
	then
		SERVICEPORT="unassigned\t\t$SERVICE/tcp"
	fi
	echo -e "$HOST\t$SERVICEPORT"
done
