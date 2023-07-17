#/bin/bash 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# Frank Hirtz <fhirtz@redhat> 2006-2013
#
# Version 1.13
# 1.13: Add spacing to timestamps to make them more readable
# 1.12: Add timestamps to iostat,iostatx,vmstat logs
# 1.11: Make tmp target directory a more easily set variable
# 1.10: Add nfs stats gathering
#	Clean up error handling/redirection
#	Add basic input validation
#	Gather cmdline
# 1.9:  Make cleanup better targeted
#       Drop the 'ps' -m parameter to make parsing it's output easier
#       Clean up RLS/LLS handling and hide the option by default 
# 1.8:  Add zoneinfo and buddyinfo collection
#       Fix directory cleanup to remove /tmp directories
# 1.7:  Change locale to make time format easier to parse automatically
# 1.6:  Change ps to output more information

VERSION=1.13
export LC_ALL=C


usage ()
{
	echo ""
	echo "profiler.sh <interval (sec)>";
	#echo "profiler.sh <interval (sec)> [<local dir> <remote dir> (optional)]";
	#echo "<local dir> <remote dir> params are to time 'ls' calls for a local and remote fs";
	#echo "For example:";
	#echo "$0 30 /tmp /mount/remote";
	echo "";
	exit;
}

get_remote_ls ()
{
	LOG=$LOGPATH/rls.log

	date >> $LOG
        echo "------------------------" >> $LOG
	/usr/bin/time -o $LOG --append ls $RLSDIR > /dev/null 2>&1;
	echo "">> $LOG
}

get_local_ls ()
{
	LOG=$LOGPATH/lls.log

	date >> $LOG
        echo "------------------------" >> $LOG
	/usr/bin/time -o $LOG --append ls /usr/bin > /dev/null 2>&1;
	echo "">> $LOG
}

get_netstat ()
{
	LOG=$LOGPATH/netstat.log

	date >> $LOG
	echo "------------------------" >> $LOG
	/bin/netstat -ta >> $LOG 2>&1
	echo "">> $LOG

}
	
get_interrupts ()
{
	LOG=$LOGPATH/interrupts.log

	date >> $LOG
	echo "------------------------" >> $LOG
	cat /proc/interrupts >> $LOG 2>&1
	echo "" >> $LOG

}

get_slabinfo ()
{
	LOG=$LOGPATH/slabinfo.log

	date >> $LOG
	echo "------------------------" >> $LOG
	cat /proc/slabinfo >> $LOG 2>&1
	echo "" >> $LOG

}

get_meminfo ()
{
	LOG=$LOGPATH/meminfo.log

	date >> $LOG
	echo "------------------------" >> $LOG
	cat /proc/meminfo >> $LOG 2>&1
	echo "" >> $LOG

}

get_zoneinfo ()
{
	LOG=$LOGPATH/zoneinfo.log

	date >> $LOG
	echo "------------------------" >> $LOG
	cat /proc/zoneinfo >> $LOG 2>&1
	echo "" >> $LOG

}

get_buddyinfo ()
{
	LOG=$LOGPATH/buddyinfo.log

	date >> $LOG
	echo "------------------------" >> $LOG
	cat /proc/buddyinfo >> $LOG 2>&1
	echo "" >> $LOG

}

get_ps ()
{
	LOG=$LOGPATH/ps.log

	date >> $LOG
	echo "------------------------" >> $LOG
	/bin/ps -eo pid,user,ppid,pgid,nlwp,lwp,stat,wchan:24,pcpu,psr,nice,pmem,vsz:10,rss:10,size:10,start,time,cmd >> $LOG 2>&1 
	echo "" >> $LOG
}

get_ethtoolstats ()
{
	LOG=$LOGPATH/ethtoolstats.log

	date >> $LOG
	echo "------------------------" >> $LOG
	for IFACE in $IFACES; do
		echo -n "$IFACE " >> $LOG
		/sbin/ethtool -S $IFACE >> $LOG 2>&1
		echo "" >> $LOG
	done
}

get_netstats()
{
	LOG=$LOGPATH/netstats.log

	date >> $LOG
	echo "------------------------" >> $LOG
	/bin/netstat -sa >> $LOG 2>&1
	echo "" >> $LOG
}

get_nfsstat ()
{
	LOG=$LOGPATH/nfsstat.log
	date >> $LOG
        echo "------------------------" >> $LOG
	/usr/sbin/nfsstat -v >> $LOG 2>&1
	echo "">> $LOG
}

add_background_timestamps ()
{
	
	echo "------------------------" >> $1
	date >> $1
	echo "------------------------" >> $1
}

### END FUNCTION DEFINITIONS ###

## Check our input ##
if [ "$#" -ne "1" -a "$#" -ne "3" ];then 
	usage
 	exit
fi

## Check that our interval is in fact a number
if [ $1 -eq $1 2> /dev/null ]; then
	INTERVAL=$1;
else
	echo "Invalid interval specified: $1";
	usage
	exit
fi

if [ "$#" -eq "3" ]; then
	LLSDIR=$2
	RLSDIR=$3
	if [ ! -x $LLSDIR ]; then
		echo "Error: $LLSDIR not readable";
		exit 2;
	fi
	if [ ! -x $RLSDIR ]; then
		echo "Error: $RLSDIR not readable";
		exit 2;
	fi
fi

### Capture the profile
TMPDIR="/tmp"
LOGNAME=`hostname -s`.`date +%b%d-%H.%M`
LOGDIR=$(mktemp -d "$TMPDIR"/rh-profiler.XXXXXX)
LOGPATH=$LOGDIR/$LOGNAME
IFACES=`ifconfig | grep eth | awk '{print $1}'`

echo "Profiler Version: $VERSION"
echo "Writing to $LOGPATH"
echo "File will be saved as $TMPDIR/$LOGNAME.tar.bz2"
echo "Press CTRL-C when done testing."

if [ ! -e $LOGPATH ]; then
	mkdir -p $LOGPATH 
	if [ $? -ne 0 ]; then
		exit 1;
	fi
fi
### Gather some data before we begin
cat /proc/cmdline > $LOGPATH/cmdline

echo $VERSION > $LOGPATH/profiler_version

date >> $LOGPATH/netstats.begin.log
/bin/netstat -sa >> $LOGPATH/netstats.begin.log 2>&1

date >> $LOGPATH/numastat.begin.log
/usr/bin/numastat >> $LOGPATH/numastat.begin.log 2>&1

date >> $LOGPATH/nfsstat_mounts
/usr/sbin/nfsstat -m >> $LOGPATH/nfsstat_mounts 2>&1

date >> $LOGPATH/nfsd_before.log
cat /proc/net/rpc/nfsd >> $LOGPATH/nfsd_before.log 2>&1

# These commands that will be run in the background for the duration
date >> $LOGPATH/vmstat.log
echo "Running every $INTERVAL seconds" >> $LOGPATH/vmstat.log
echo "------------------------" >> $LOGPATH/vmstat.log
vmstat $INTERVAL >> $LOGPATH/vmstat.log  2>&1 &
VMSTATPID=$!

date >> $LOGPATH/iostat.log
echo "Running every $INTERVAL seconds" >> $LOGPATH/iostat.log
echo "------------------------" >> $LOGPATH/iostat.log
iostat $INTERVAL >> $LOGPATH/iostat.log  2>&1 &
IOSTATPID=$!

date >> $LOGPATH/iostatx.log
echo "Running every $INTERVAL seconds" >> $LOGPATH/iostatx.log
echo "------------------------" >> $LOGPATH/iostatx.log
iostat -x $INTERVAL >> $LOGPATH/iostatx.log  2>&1 &
IOSTATXPID=$!

date >> $LOGPATH/mpstat.log
echo "Running every $INTERVAL seconds" >> $LOGPATH/mpstat.log
echo "------------------------" >> $LOGPATH/mpstat.log
mpstat -P ALL $INTERVAL >> $LOGPATH/mpstat.log 2>&1 &
MPSTATPID=$!
# End background commands

while true; do {

trap "echo 'Data gathering complete. Saving Data';date > $LOGPATH/netstats.end.log; /bin/netstat -sa >> $LOGPATH/netstats.end.log 2>&1; /usr/bin/numastat >> $LOGPATH/numastat.end.log 2>&1; cat /proc/net/rpc/nfsd > $LOGPATH/nfsd_after.log 2>&1; kill -TERM $VMSTATPID 2> /dev/null; kill -TERM $IOSTATPID 2> /dev/null; kill -TERM $IOSTATXPID 2> /dev/null; kill -TERM $MPSTATPID 2> /dev/null;if [ -r /var/log/messages ]; then cp /var/log/messages $LOGPATH/messages.log; fi; if [ -r /var/log/dmesg ]; then cp /var/log/dmesg $LOGPATH/dmesg.log; fi; cd $LOGPATH; cd ..; tar jcf $LOGNAME.tar.bz2 $LOGNAME; mv $LOGNAME.tar.bz2 /tmp; rm -rf $LOGPATH/*.log; rm -f $LOGPATH/cmdline; rm -f $LOGPATH/nfsstat_mounts; rm -f $LOGPATH/profiler_version; rmdir $LOGPATH; rmdir $LOGDIR; exit;" INT


get_netstat
get_netstats
get_interrupts
get_slabinfo
get_meminfo
get_zoneinfo
get_buddyinfo
get_ps
get_ethtoolstats
get_nfsstat
add_background_timestamps $LOGPATH/vmstat.log
add_background_timestamps $LOGPATH/iostat.log
add_background_timestamps $LOGPATH/iostatx.log

if [ "$#" -eq "3" ]; then
	if [ -d $LLSDIR ]; then
		get_local_ls
	else
		echo "Local directory $LLSDIR doesn't exist"
		exit 1
	fi
	if [ -d $RLSDIR ]; then
		get_remote_ls
	else
		echo "Remote directory $RLSDIR doesn't exist"
		exit 1
	fi
fi

echo -n "."

sleep $INTERVAL;
}
done;
