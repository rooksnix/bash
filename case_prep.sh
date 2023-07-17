#!/bin/bash
CASE=$1
BASE=~/Cases
mkdir $BASE/$CASE
cd $BASE/$CASE
~/scripts/support/getattachments.py
for x in `ls | grep sos|grep -v md5` ; do tar xf $x; done;
