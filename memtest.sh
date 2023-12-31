#!/bin/bash
#
# memtest
#
# A general purpose memory tester script, with options for enabling extra
# simultaneous tests in an attempt to test the capacity of the power supply
# in the machine.  You can find the original source of this script and
# additional documentation on its usage by visiting my work web page at
# http://people.redhat.com/~dledford/
#
# Author: Doug Ledford <dledford@redhat.com> + contributors
#
# (C) Copyright 2000-2002,2008,2012 Doug Ledford; Red Hat, Inc.
# This shell script is released under the terms of the GNU General
# Public License Version 3, June 2007.  If you do not have a copy
# of the GNU General Public License Version 3, then one may be
# retrieved from http://people.redhat.com/~dledford/gpl.txt
#

# Here we set the defaults for this script.  You can edit these to
# make permanent changes, or you can pass in command line arguments to
# make temporary changes
TEST_DIR=/tmp
SOURCE_FILE=linux.tar.bz2
NR_PASSES=20
HELP=
PARALLEL=no
EXTRACT=yes
MB=1048576

usage ()
{
	echo "Usage: `basename $0` [options]"
	echo "Options:"
	echo "	-u	Display this usage info"
	echo "	-h	Give full help description of each option"
	echo "	-t <test_directory>"
	if [ -n "$HELP" ]; then
	echo "		The directory where we will unpack the tarballs and run"
	echo "		the diff comparisons.  Ideally, this will hit all local"
	echo "		disks by being part of a software raid array (if there"
	echo "		is more than one local disk anyway).  It can also be on"
	echo "		a network file server if you have both a very fast disk"
	echo "		array on the server, and a very fast network inter-"
	echo "		connect between the server and your machine (10GBit/s"
	echo "		or faster is needed in order to out run a single modern"
	echo "		SATA hard drive that's local)."
	fi
	echo "		Default: /tmp"
	echo "	-s <source_file>"
	if [ -n "$HELP" ]; then
	echo "		The file we will decompress and untar to create the"
	echo "		file trees we intend to compare against each other.  I"
	echo "		recommend that this file be a tar.bz2 file and that you"
	echo "		have the parallel bzip2 utility (pbzip2) installed on"
	echo "		your machine.  This at least allows the bzip2 unzip"
	echo "		operation to use all CPUs when not running the test in"
	echo "		parallel mode.  This file is expected to be in the test"
	echo "		directory.  You can use a relative path from the test"
	echo "		directory in case it is located somewhere else."
	fi
	echo "		Default: linux.tar.bz2"
	echo "	-x	Toggle whether or not we extract the contents of the"
	echo "		tarball, or just decompress it."
	if [ -n "$HELP" ]; then
	echo "		In the event that extracting lots of small files slows"
	echo "		your disk subsystem down too much and our overall write"
	echo "		speed falls too low, it won't make an effective test of"
	echo "		the disk DMA operations against CPU memory operations."
	echo "		If your write speeds aren't high enough, try disabling"
	echo "		extraction and see if that speeds things up."
	fi
	echo "		Default: extract the contents"
	echo "	-n <number_of_passes>"
	if [ -n "$HELP" ]; then
	echo "		How many times we will run the test before we consider"
	echo "		it complete.  It's possible to pass most of the time"
	echo "		and only fail once in a while, so we run the whole"
	echo "		thing multiple times by default."
	fi
	echo "		Default: 20"
	echo "	-m <megs_per_copy>"
	if [ -n "$HELP" ]; then
	echo "		How many megabytes does the uncompressed tarball use on"
	echo "		the filesystem.  We assume a roughly 75% compression"
	echo "		ratio in the compressed tarball if the compression used"
	echo "		is gzip, and 80% if the compression is bzip2.  So we"
	echo "		take 4 or 5 times the size of the file depending on the"
	echo "		file extension."
	fi
	echo "		Default: 4 * sizeof source .gz files,"
	echo "			 5 * sizeof source .bz2 files"
	echo "	-c <number_of_copies>"
	if [ -n "$HELP" ]; then
	echo "		We normally just calculate how many copies of the"
	echo "		tarball to extract in order to be roughly 1.5 times"
	echo "		physical memory size, but you can pass in a number if"
	echo "		this doesn't work for some reason."
	fi
	echo "		Default: physical ram size * 1.5 / megs_per_copy"
	echo "	-p	Toggles whether or not we will extract and diff all the"
	echo "		source trees in parallel or serial."
	if [ -n "$HELP" ]; then
	echo "		Most linux filesystems will be much faster when running"
	echo "		tests serially.  It tends to bog the drives down when"
	echo "		the heads have to seek back and forth a lot to satisfy"
	echo "		multiple readers/writers acting simultaneously.  But,"
	echo "		parallel operations will tend to create much higher"
	echo "		memory pressure and can be useful testing the virtual"
	echo "		memory subsystem, so it's available as an option here."
	fi
	echo "		Default: serial"
	echo "	-i	Just parse the arguments and say what figures we came"
	echo "		up with and then exit."
	exit 1
}

clean_exit()
{
	# Kill any children that might be in the background, as well as any
	# currently running foreground apps, then cleanup, then exit
	for job in `jobs -p`; do
		kill -9 $job >/dev/null 2>&1
		while [ -n "`ps --no-heading $job`" ]; do sleep .2s; done
	done
	echo -n "Waiting for all pipelines to exit..."
	wait
	echo "done."
	echo -n "Cleaning up work directory..."
	rm -fr memtest-work
	echo "done."
	popd
	exit $1
}

trap_handler()
{
	echo " test aborted by interrupt."
	clean_exit 1
}

while [ -n "$1" ]; do
	case "$1" in
	-u)
		USAGE=1
		shift
		;;
	-h)
		HELP=1
		shift
		;;
	-t)
		TEST_DIR="$2"
		shift 2
		;;
	-s)
		SOURCE_FILE="$2"
		shift 2
		;;
	-x)
		[ $EXTRACT = yes ] && EXTRACT=no || EXTRACT=yes
		shift
		;;
	-n)
		NR_PASSES="$2"
		shift 2
		;;
	-m)
		MEGS_PER_COPY="$2"
		shift 2
		;;
	-c)
		NR_COPIES="$2"
		shift 2
		;;
	-p)
		[ $PARALLEL = yes ] && PARALLEL=no || PARALLEL=yes
		shift
		;;
	-i)
		JUST_INFO=1
		shift
		;;
	*)
		echo "Unknown option $1"
		USAGE=1
		shift
		;;
	esac
done

[ -n "$USAGE" ] && usage

if [ ! -f "$TEST_DIR/$SOURCE_FILE" ]; then
  echo "Missing source file $TEST_DIR/$SOURCE_FILE"
  usage
fi

BZIP2=`file -b "$TEST_DIR/$SOURCE_FILE" | grep bzip2`
if [ -n "$BZIP2" ]; then
	COMPRESS_RATIO=6
	COMPRESS_PROG=`which pbzip2 2>/dev/null`
	[ -z "$COMPRESS_PROG" ] && COMPRESS_PROG=`which bzip2 2>/dev/null`
else
	COMPRESS_RATIO=4
	COMPRESS_PROG=`which gzip 2>/dev/null`
fi

# Guess how many megs the unpacked archive is.
if [ -z "$MEGS_PER_COPY" ]; then
  ARCHIVE_SIZE_MB=$(ls -l --block-size=$MB "$TEST_DIR/$SOURCE_FILE" | awk '{ print $5 }')
  EXTRACTED_SIZE_MB=$(echo "$ARCHIVE_SIZE_MB * $COMPRESS_RATIO" | bc)
fi

# How many trees do we have to unpack in order to make our trees be larger
# than physical RAM?  We shoot for 1.5 times physical RAM size just to be
# sure we unpack plenty and to compensate in case our estimate of unpacked
# size is inaccurate. 
if [ -z "$NR_COPIES" ]; then
  MEM_TOTAL_MB=$(free -m | awk '/^Mem:/ { print $2 }')
  NR_COPIES=$(echo "$MEM_TOTAL_MB.000 * 1.500 / $EXTRACTED_SIZE_MB" | bc)
  MIN_FREE_DISK=$[ $MEM_TOTAL_MB + $MEM_TOTAL_MB ]
fi

# Check for disk free space and bail if we don't have enough
DISK_FREE_MB=$(df -B$MB $TEST_DIR | awk '!/^Filesystem/{ printf $2 }')
DISK_FS_TYPE=$(df -T $TEST_DIR | awk '!/^Filesystem/{ print $2 }')

if [ $MIN_FREE_DISK -gt $DISK_FREE_MB ]; then
	echo "Error: Not enough free disk space in test directory"
	echo "	Based on memory size of machine, you need at least"
	echo "	$MIN_FREE_DISK MB of free space and you only have"
	echo "	$DISK_FREE_MB MB at the moment.  Please free up"
	echo "	disk space or set TEST_DIR to a directory on a"
	echo "	filesystem that has enough free space to run the test."
	echo
	JUST_INFO=1
fi

echo "TEST_DIR:		$TEST_DIR"
echo "DISK_FREE_MB:			$DISK_FREE_MB"
echo "DISK_FS_TYPE:			$DISK_FS_TYPE"
echo "SOURCE_FILE:			$SOURCE_FILE"
echo "COMPRESS_PROG:				$COMPRESS_PROG"
echo "COMPRESS_RATIO:				$COMPRESS_RATIO"
echo "ARCHIVE_SIZE_MB:			$ARCHIVE_SIZE_MB"
echo "EXTRACTED_SIZE_MB:			$EXTRACTED_SIZE_MB"
echo "MEM_TOTAL_MB:		$MEM_TOTAL_MB"
echo "NR_COPIES:			$NR_COPIES"
echo "NR_PASSES:		$NR_PASSES"
echo "PARALLEL:		$PARALLEL"
echo "EXTRACT:		$EXTRACT"
echo
if [ -n "$JUST_INFO" ]; then
  exit 0
fi

# OK, options parsed and sanity tests passed, here starts the actual work
pushd $TEST_DIR

# Set our trap handler
trap 'trap_handler' 2 9 15

# Remove any possible left over directories from a cancelled previous run
rm -fr memtest-work

# Unpack the one copy of the source tree that we will be comparing against
echo -n "Creating comparison source..."
if [ $EXTRACT = yes ]; then
  mkdir -p memtest-work/original
  $COMPRESS_PROG -dc $SOURCE_FILE 2>/dev/null | tar -xf - -C memtest-work/original >/dev/null 2>&1 &
  wait
  if [ $? -gt 128 ]; then
    clean_exit 1
  fi
else
  mkdir -p memtest-work
  $COMPRESS_PROG -dc $SOURCE_FILE > memtest-work/original 2>/dev/null &
  wait
  if [ $? -gt 128 ]; then
    clean_exit 1
  fi
fi
echo "done."

i=1
while [ "$i" -le "$NR_PASSES" ]; do
  echo -n "Starting test pass #$i: "
  j=0
  echo -n "unpacking"
  while [ "$j" -lt "$NR_COPIES" ]; do
    if [ $PARALLEL = yes ]; then
      if [ $EXTRACT = yes ]; then
        mkdir -p memtest-work/$j
	$COMPRESS_PROG -dc $SOURCE_FILE 2>/dev/null | tar -xf - -C memtest-work/$j >/dev/null 2>&1 &
      else
        $COMPRESS_PROG -dc $SOURCE_FILE > memtest-work/$j 2>/dev/null &
      fi
    else
      if [ $EXTRACT = yes ]; then
	mkdir -p memtest-work/$j
	$COMPRESS_PROG -dc $SOURCE_FILE 2>/dev/null | tar -xf - -C memtest-work/$j >/dev/null 2>&1 &
	wait
	if [ $? -gt 128 ]; then
	  clean_exit 1
	fi
      else
	$COMPRESS_PROG -dc $SOURCE_FILE > memtest-work/$j 2>/dev/null &
	wait
	if [ $? -gt 128 ]; then
	  clean_exit 1
	fi
      fi
    fi
    j=$[ $j + 1 ]
  done
  if [ $PARALLEL = yes ]; then
    wait
    if [ $? -gt 128 ]; then
      clean_exit 1
    fi
  fi
  j=0
  echo -n ", comparing"
  while [ "$j" -lt "$NR_COPIES" ]; do
    if [ $PARALLEL = yes ]; then
      if [ $EXTRACT = yes ]; then
        diff -uprN memtest-work/original memtest-work/$j &
      else
        cmp memtest-work/original memtest-work/$j &
      fi
    else
      if [ $EXTRACT = yes ]; then
        diff -uprN memtest-work/original memtest-work/$j &
	wait
	if [ $? -gt 128 ]; then
	  clean_exit 1
	fi
      else
        cmp memtest-work/original memtest-work/$j &
	wait
	if [ $? -gt 128 ]; then
	  clean_exit 1
	fi
      fi
    fi
    j=$[ $j + 1 ]
  done
  if [ $PARALLEL = yes ]; then
    wait
    if [ $? -gt 128 ]; then
      clean_exit 1
    fi
  fi
  j=0
  echo -n ", removing"
  while [ "$j" -lt "$NR_COPIES" ]; do
    rm -fr memtest-work/$j &
    wait
    if [ $? -gt 128 ]; then
      clean_exit 1
    fi
    j=$[ $j + 1 ]
  done
  echo ", done."
  i=$[ $i + 1 ]
done

clean_exit 0


