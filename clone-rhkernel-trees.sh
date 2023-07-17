#!/bin/sh
# clone all rhel git trees
# MAINTAINER: Dave Wysochanski <dwysocha@redhat.com>
#
GIT_ENGINEERING=git.engineering.redhat.com
GIT_APP_ENG_BOS=git.app.eng.bos.redhat.com
#
# Upstream
#
echo Cloning upstream git tree
mkdir upstream
git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git upstream
#git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git upstream-firmware
#
# RHEL4
#
echo Cloning rhel4 git tree
mkdir rhel4
git clone git://$GIT_APP_ENG_BOS/rhel-4.git rhel4
#
# RHEL5
#
echo Cloning rhel5 git tree
mkdir rhel5
git clone git://$GIT_APP_ENG_BOS/rhel5/kernel.git rhel5
cd rhel5
git remote add upstream ../upstream
for d in 2 3 4 5 6 7 8 9; do
	# Missing 5.2.z and 5.5.z now
	if [ $d -eq 4 ]; then
  		echo Using remote for rhel5.$d.z git tree
  		git remote add rhel5.$d.z git://$GIT_ENGINEERING/users/plougher/rhel5.$d.z/kernel.git
	fi
	if [ $d -eq 3 -o $d -eq 6 -o $d -eq 7 -o $d -eq 8 ]; then
  		echo Using remote for rhel5.$d.z git tree
  		git remote add rhel5.$d.z git://$GIT_APP_ENG_BOS/rhel-5.$d.z/kernel.git
	fi
	# No idea why we can't keep with the same format but apparently we can't
	if [ $d -eq 9 ]; then
		git remote add rhel5.9.z git://$GIT_APP_ENG_BOS/rhel-5.$d.z-kernel.git
	fi

done
git fetch --all
cd ../
#git clone git://github.com/torvalds/linux.git upstream
#
# RHEL6
#
echo Cloning rhel6 git tree
mkdir rhel6
git clone --reference upstream git://$GIT_APP_ENG_BOS/rhel6.git rhel6
cd rhel6
git remote add upstream ../upstream
for d in 0 1 2 3 4; do
  echo Using remote for rhel6.$d.z git tree
  git remote add rhel6.$d.z git://$GIT_APP_ENG_BOS/rhel-6.$d.z.git
done
git fetch --all
cd ../
#
# RHEL7
#
mkdir rhel7
git clone --reference upstream git://$GIT_APP_ENG_BOS/rhel7.git
cd rhel7
git remote add upstream ../upstream
