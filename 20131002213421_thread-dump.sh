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
# Sterling Alexander <stalexan@redhat> 2013
#
# Version 1.0

VERSION=1.0
export LC_ALL=C

SYSRQ=0

usage ()
{
        echo ""
        echo "Usage:  $0 <interval (sec)>";
        echo "";
        exit;
}


## Check our input ##
if [ "$#" -ne "1" -a "$#" -ne "2" ];then
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

get_sysrq_t ()
{
  # check for sysrq enabled
  if [ $(cat /proc/sys/kernel/sysrq) -eq "0" ]; then
    echo " -- Enabling sysrq for testing purposes...."
    SYSRQ=1
    echo "1" >> /proc/sys/kernel/sysrq
  fi

  echo t > /proc/sysrq-trigger
}

function finish () 
{
  echo ""
  echo " -- Cleaning up....";
  if [[ $SYSRQ -eq "1" ]]; then 
    echo " -- Reseting sysrq to original value..."
    echo 0 > /proc/sys/kernel/sysrq 
  fi 
  exit;
}

while true; do {

  trap finish INT

  echo "==========| Thread Dump Mark |==========" >> /var/log/messages
  get_sysrq_t
  echo -n "."
  sleep $INTERVAL;
}
done 
    