#!/bin/sh
#
# Before putting this script in place, run:
# mv /sbin/shutdown /sbin/shutdown.real
#
# then copy this script to /sbin/shutdown and make it executable
# you may also need to do a restorecon on it if SELinux is around

parent=$PPID

ps_out=`ps axefo 'pid,user,command' | grep -E "^\s*$parent"`

logger "Shutdown called by: $ps_out"

shutdown.real "$@"
