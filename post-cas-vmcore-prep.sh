#!/bin/bash
#
# Do extended preparation on a vmcore which has completed processing by CAS
#
# First, extract and create 'crash_new' which will load modules into crash session
# FIXME: need to load xen version if it's a 'xen' kernel
echo "Running get_modules_debug to create 'crash_new' and load modules into crash"
/cores/debuginfo/get_modules_debug
#
# Next, load our expect commands to gather further info from crash
#
echo "Running expect script to load crash and run some other data gathering commands"
/cores/crashext/post-cas-vmcore-prep.exp ./crash_new
#
# Now run other post processing tools on the above generated files
#
echo "Running ps_dtime and bt_filter.py"
/cores/crashext/ps_dtime > ./ps_dtime.txt
/cores/crashext/bt_filter.py bt-all.txt > bt_filter.txt
