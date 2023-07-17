#!/bin/bash

find -name ethtool_-i_* 2> /dev/null | while read f; do
	sosbase="${f/sos_commands*}"
	businfo="$(sed -n '/^bus-info: /{s///;s/^[^:]\+://;p}' "$f")"
	lspci="$sosbase/lspci"
	[ -e "$lspci" ] || continue
	sed -n "/^$businfo /{s///;p}" "$lspci" | sed ':a;$!N;s/\n/ /;ta'
done > nics

oldifs="$IFS"
IFS="$(echo -e '\n')"
declare -A hist
while read line; do
	if [ "${hist[$line]}" == "" ]; then
		hist["$line"]=0
	fi
	hist["$line"]=$((${hist["$line"]}+1))
done < nics

# As I don't know how to list array indexes, re-read nics again ;P
sort -u nics | while read line; do
	echo "${hist[$line]} $line"
done | sort -n

