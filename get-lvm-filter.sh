#!/bin/bash
# Building an LVM filter, simple method.
# Requires: awk, pvs
#
pvs -a --config 'devices { filter = [ "a|.*|" ] }' --noheadings -opv_name,fmt,vg_name | awk 'BEGIN { f = ""; } NF == 3 { n = "\42a|"$1"|\42, "; f = f n; } END { print "Suggested filter line for /etc/lvm/lvm.conf:\n filter = [ "f"\"r|.*|\" ]" }'
