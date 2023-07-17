#!/bin/bash

################################################################################
##
##  smp2hex.sh
##
##             - a simple script to do smp2hex math for you.
##
##             - by itself, this script accomplishes nothing, it just
##               echos it's output.
##             - you need to write something else to persist it's output
##               to /proc/irq/$IRQ/smp_affinity
##
##  MAINTAINER:  jeder@redhat.com
##
##
################################################################################

################################################################################
##  Define Global Variables and Functions

# IRQ_CPU is a list of cores that you want to process your IRQs.
# IFACE is the physical interface you're working on.
# This script could be extended to loop through interfaces

IRQ_CPU=0,1,2,3
IFACE=eth0

function nic_affinity()
{
    IRQ=`grep $IFACE /proc/interrupts | awk -F: '{print $1}'|sed -e 's/\ //g'`
        echo "smp2hex doing bitwise OR of hexadecimal values for each cpu" 
        hex_mask=0 
        for i in $(echo $IRQ_CPU | tr ',' ' '); do 
		d=$((2**${i})); 
		o=$(printf "%x" $d) 
			hex_mask=$(( $o | $hex_mask ))
        done 
	echo "Interface:       $IFACE"
	echo "Bind to Cores:   $IRQ_CPU"
	echo "Hex mask is:     $hex_mask"
	echo "IRQ is:          $IRQ"
        echo "Example command: echo $hex_mask > /proc/irq/$IRQ/smp_affinity"
} 

nic_affinity
