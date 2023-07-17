#!/bin/sh
# Create common branches for trees created from clone-rhkernel-trees.sh
# MAINTAINER: Dave Wysochanski <dwysocha@redhat.com>
#
# See https://home.corp.redhat.com/node/67632
# RHEL4
# - no tags; use something like this to find version
# git log | grep -A 5 ^commit | egrep '(\.EL|^commit)' | less
#
# RHEL5 https://home.corp.redhat.com/wiki/rhel-kernel-version-table-rhel5-tikanga
cd rhel5
git checkout -f -b 2.6.18-92.el5-rhel5.2 2.6.18-92.el5
git checkout -f -b 2.6.18-128.el5-rhel5.3 2.6.18-128.el5
git checkout -f -b 2.6.18-164.el5-rhel5.4 2.6.18-164.el5
git checkout -f -b 2.6.18-194.el5-rhel5.5 2.6.18-194.el5
git checkout -f -b 2.6.18-238.el5-rhel5.6 2.6.18-238.el5
git checkout -f -b 2.6.18-274.el5-rhel5.7 2.6.18-274.el5
git checkout -f -b 2.6.18-308.el5-rhel5.8 2.6.18-308.el5
git checkout -f -b 2.6.18-348.el5-rhel5.8 2.6.18-348.el5
#git checkout -f -b 2.6.18-128.39.1.el5.3.z 2.6.18-128.39.1.el5
#git checkout -f -b 2.6.18-164.38.1.el5.4.z 2.6.18-164.38.1.el5
#git checkout -f -b 2.6.18-194.32.1.el5.5.z 2.6.18-194.32.1.el5
#git checkout -f -b 2.6.18-238.46.1.el5.6.z 2.6.18-238.46.1.el5
#git checkout -f -b 2.6.18-274.18.1.el5.7.z 2.6.18-274.18.1.el5
#git checkout -f -b 2.6.18-308.24.1.el5.8.z 2.6.18-308.24.1.el5
cd ..
# RHEL6: https://home.corp.redhat.com/wiki/rhel-kernel-version-table-rhel6-santiago
cd rhel6
git checkout -f -b 2.6.32-71.el6.0 kernel-2.6.32-71.el6
git checkout -f -b 2.6.32-131.0.15.el6.1 kernel-2.6.32-131.0.15.el6
git checkout -f -b 2.6.32-220.el6.2 kernel-2.6.32-220.el6
git checkout -f -b 2.6.32-279.el6.3 kernel-2.6.32-279.el6
git checkout -f -b 2.6.32-358.el6.4 kernel-2.6.32-358.el6
#git checkout -f -b 2.6.32-71.40.1.el6.0.z kernel-2.6.32-71.40.1.el6
#git checkout -f -b 2.6.32-131.35.1.el6.1.z kernel-2.6.32-131.35.1.el6
#git checkout -f -b 2.6.32-220.30.1.el6.2.z kernel-2.6.32-220.30.1.el6
#git checkout -f -b 2.6.32-279.19.1.el6.3.z kernel-2.6.32-279.19.1.el6
#git checkout -f -b 2.6.32-358.2.1.el6.4.z kernel-2.6.32-358.2.1.el6
