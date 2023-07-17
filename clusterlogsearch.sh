#!/bin/sh  
######################################################################  
# findClusterMsgs.sh  
#  
# Author: Shane Bradley(sbradley@redhat.com)  
# Creation Date: 2013-05-07  
# Version: 1.1  
# Description: This script searches for all the log files (messages*) for a list  
# of strings. The list of lines found that contain the string then are sorted  
# and printed to console.  
#  
# TODO:  
# * Need qdisk messages that should be searched.  
#  
# usage:  
# $ ./findClusterMsgs.sh <path to directory to search>  
######################################################################  
  
# The list of strings that will be searched for in the files found.  
SEARCH_STRINGS=( "fencing node" "fence_" "Updating cluster\.conf" \  
    "The token was lost in the OPERATIONAL state" \  
    "we rejoined the cluster without a full restart" \  
    "A processor failed, forming new configuration" \  
    "qdiskd*evicted");  
  
function usage() {  
    echo "USAGE: $ ./findClusterMsgs.sh <path to directory to search>";  
    exit $1;  
}  
  
if [ -z $1 ]; then  
    echo "Please give a path to search from, script will exit.";  
    usage 2;  
elif [ ! -e $1 ]; then  
    echo "The path does not exist: $1"  
    usage 2;  
elif [ ! -d $1 ]; then  
    echo "The path is not a directory: $1"  
    usage 2;  
fi  
  
echo "Searching messages file for cluster related message strings: $1";  
grep_regular_expressions=""  
for i in "${SEARCH_STRINGS[@]}"  
do  
    # Escape out peroid of cluster.conf  
    i=${i//cluster.conf/\cluster\.conf}  
    # Replace whitespaces with peroids for re.  
    i=${i// /.}  
    if [ -z $grep_regular_expressions ]; then  
        grep_regular_expressions="($i"  
    else  
        grep_regular_expressions="$grep_regular_expressions|$i"  
    fi  
done;  
grep_regular_expressions="$grep_regular_expressions)"  
  
# find $1 -iname messages -exec egrep "$grep_regular_expressions" {} \; | uniq | sort  -k1M -k2,3 -s;  
find $1 -iname messages* -exec egrep "$grep_regular_expressions" {} \; | uniq | sort  -k1M -k2,3 -s;  
  
# Do a count of the number of "" messages found in all the logs  
echo -e "\n-------------------------------------------------------------------------------------------------\n"  
echo "Searching for log entries that contain the string \"[TOTEM] Retransmit List\". ";  
echo -n "The number of entries found: "  
find $1 -iname messages* -exec grep "\[TOTEM.\] Retransmit List" {} \; | uniq | wc -l  
echo -e "\nIf there are lots of logs for the above message then you may want to review this article:"  
echo "- https://access.redhat.com/knowledge/solutions/38510"  
exit; 
