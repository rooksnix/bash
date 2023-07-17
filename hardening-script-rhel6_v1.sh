#!/bin/bash

red='\e[0;31m'
green='\e[0;32m'
NC='\e[0m' # No Color
blink='\e[0;5m'


if [ ! -f /etc/sysctl.conf-org ]; then
cp  /etc/sysctl.conf /etc/sysctl.conf-org
fi

#echo -e "\n\n###Adding security related kernel parameters by Security Hardening Auto Script###" >> /etc/sysctl.conf
#echo "net.ipv4.ip.forward=0"  >> /etc/sysctl.conf
#echo done

echo "#############################################################"


echo "#####Making server default runlevel to 3#####" 

if [ ! -f /etc/inittab-org ]; then
cp /etc/inittab /etc/inittab-org
fi

/bin/sed -i 's/id:5:initdefault:/id:3:initdefault:/g' /etc/inittab

echo "#####Default Run Label 3 has set#####"

echo "#############################################################"

echo "#####Making SSH ROOT Login Disabled#####"

if [ ! -f /etc/ssh/sshd_config-org ]; then
	cp /etc/ssh/sshd_config /etc/ssh/sshd_config-org
fi

echo -e "\n###Added SSH Root Restriction by Security Hardening Auto Script ###" >> /etc/ssh/sshd_config 
echo "PermitRootLogin no" >> /etc/ssh/sshd_config 
echo `/etc/init.d/sshd reload`

echo "SSH Root Login has disabled"

echo "#############################################################"

echo "#####Making SSH ROOT Login disabled to Console and tty1 to tty6#####"

if [ ! -f /etc/securetty-org ]; then
	cp /etc/securetty /etc/securetty-org
fi


echo -e "console\ntty1\ntty2\ntty3\ntty4\ntty5\ntty6"> /etc/securetty

echo "ROOT login has restricted to Console screen only"

echo "#############################################################"

echo "#####Adding PRSADM user#####"

#useradd prsadm -d /home/prsadm -p '$1$B2hTB0$wCqcwugNVRe22ErcuyUYi.'
useradd prsadm -d /home/prsadm -p "\$1\$JXj8Xfcf\$ELkH8Wd9LzqZmhgOMst47."

echo "#############################################################"

echo "##### Adding Login Banner #####"

echo "############################################################################
############################################################################
                                -------------
                                W A R N I N G
                                -------------
        ########## THIS IS A PRIVATE COMPUTER SYSTEM. ##########

The use of this system is restricted to authorized users only.
Unauthorized access,use,or modification of this computer system or of
the data contained herein or in transit to/from this system constitutes
a violation. These systems and equipment are subject to monitoring to
ensure proper performance of applicable security features or procedures.
Such monitoring may result in the acquisition, recording and analysis of
all data being communicated, transmitted, processed or stored in this
system by a user.  If monitoring reveals possible evidence of criminal
activity, such evidence may be provided to law enforcement personnel.

############################################################################
############################################################################" > /etc/motd

/bin/cat /etc/motd > /etc/issue
#cat /root/banner.txt > /etc/issue
#cat /root/banner.txt > /etc/motd

echo "##### Banner has successfully Created for console, ssh and ftp login #####"

#echo "#####Set Daily Log rotation policy for 30 Days maximum for RHEL6.1#####"
#if [ ! -f /etc/logrotate-org ]; then
#	cp /etc/logrotate /etc/logrotate-org
#fi

#/bin/sed -i 's/monthly/daily/g' /etc/logrotate.conf
#/bin/sed -i 's/rotate 1/rotate 30/g' /etc/logrotate.conf
#/etc/init.d/syslog reload
#echo "#####Log Rotaion policy has enabled successfuly#####"
echo "#############################################################"

##setting Passowrd policy
echo "##### Setting Password Policy #####"
if [ ! -f /etc/login.defs-org ]; then
cp   /etc/login.defs /etc/login.defs-org
fi

sed -i s/"PASS_MAX_DAYS\t99999"/"PASS_MAX_DAYS\t30"/ /etc/login.defs
sed -i s/"PASS_MIN_DAYS\t0"/"PASS_MIN_DAYS\t7"/ /etc/login.defs
sed -i s/"PASS_MIN_LEN\t5"/"PASS_MIN_LEN\t8"/ /etc/login.defs
#cat /root/login.defs > /etc/login.defs
echo "##### Password Policy has set #####"

echo "##### Changing Root password #####"
#usermod -p '$1$1j0VB0$LS4CLgAu5iUWaycW9.DS30' root
echo "#####Root Password has successfully changed#####"
echo "#############################################################"

echo "#####Making Ctrl+Alt+Delete Disabled to restart/shutdown on RHEL6.1#####"

mv /etc/init/control-alt-delete.conf /etc/init/control-alt-delete.conf.disable
#/bin/sed -i 's/ca::ctrlaltdel/#ca::ctrlaltdel/g' /etc/inittab

echo "#####Ctrl+Alt+Delete has disabled#####"

echo "#############################################################"

if [ ! -f /etc/bashrc-org ]; then
cp 		/etc/bashrc /etc/bashrc-org
fi

echo "#####Setting Time Out Value 600 Seconds#####"
echo "#####Adding Time Out and History time format by Security Hardening Script#####" >> /etc/bashrc
echo "export TMOUT=600" >> /etc/bashrc
echo "#####Time Out has set#####"

echo "#####Setting History with Date and Time #####"
echo -e "export HISTTIMEFORMAT=\"%H:%M:%S %Y-%m-%d \"" >> /etc/bashrc
echo "#####History Date and Time has set#####"

echo "#####Making password locking after 5 Faillog attemps for RHEL6.1#####"
/bin/sed -i s/"pam_securetty.so"/"pam_securetty.so\nauth     required       pam_tally2.so deny=5 unlock_time=3600"/ /etc/pam.d/login
/bin/sed -i s/"pam_sepermit.so"/"pam_sepermit.so\nauth     required       pam_tally2.so deny=5 unlock_time=3600"/ /etc/pam.d/sshd

echo "#####Faillog attempts for password lock has enabled#####"

echo "#####Setting Grub and Single User Password#####"
## updated by vikas
if [ ! -f /boot/grub/grub.conf-org ]; then
cp /boot/grub/grub.conf /boot/grub/grub.conf-org
fi

/bin/sed -i s/"timeout=5"/"timeout=5 \npassword --md5 \$1\$JXj8Xfcf\$ELkH8Wd9LzqZmhgOMst47."/ /boot/grub/grub.conf

echo "#####Single User/Grub Password has set#####"

echo "#####ADDING PRS ADM as Sudo previledes#####"
echo "#####CIDRM users' sudo priviledges added by security hardeing auto script#####" >> /etc/sudoers
echo "prsadm         ALL=(ALL)       ALL" >> /etc/sudoers
echo "#####Sudo Previledges has added for PRSADM#####"

echo "#####Cron permission to only root USER#####"
if [ ! -f /etc/cron.deny.org ]; then
cp /etc/cron.deny /etc/cron.deny.org
fi

rm -rf /etc/cron.deny
echo "root" >> /etc/cron.allow
/etc/init.d/crond reload
echo "#####Cron has allowed to ROOT user only#####"

echo "##### Disabling Reboot and Shutdown for other Users #####"
chmod 0500  /usr/bin/consolehelper /sbin/shutdown
echo "done"


############################################################
########updated by vikas ###################################
#echo "Disble Root login from ssh"
#/usr/bin/cp  /etc/ssh/sshd_config /etc/ssh/sshd_config-org
#/bin/sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

### Password locking configuration ###
## account will be locked for 20 min ###
#/usr/bin/cp  /etc/pam.d/password-auth /etc/pam.d/password-auth-org
#echo "auth        required      pam_tally2.so  file=/var/log/tallylog deny=5 even_deny_root unlock_time=1200" >>  /etc/pam.d/password-auth
#echo "account     required      pam_tally2.so" >> /etc/pam.d/password-auth

if [ ! -f /etc/pam.d/system-auth-org ]; then
cp /etc/pam.d/system-auth /etc/pam.d/system-auth-org
fi

sed -i '/cracklib/c\password    requisite     pam_cracklib.so try_first_pass retry=5  minlen=8 minclass=4 credit=0 ucredit=1 dcredit=1 ocredit=1 type=Linux(secured_passworda)' /etc/pam.d/system-auth


## to change it timeout value
#/proc/sys/net/ipv4/tcp_keepalive_time

##to add history variable ##
#cp 		/etc/bashrc /etc/bashrc-org
#echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> /etc/bashrc
#echo 'export TMOUT=120' >> /etc/bashrc

##check telnet is exist or not##
rpm -e telnet 


#check No account have empry field
for i in `cat /etc/passwd | awk -F":" '{print $3}'`
do
        if [ $i -gt 499 ]
        then
                for j in `/bin/cat /etc/passwd | grep $i | awk -F":" '{print $1}'`
                do
                        for k in `/bin/cat /etc/shadow  | grep $j | awk -F":" '{print $2}'`
                        do
                                if [ $k == '!!' ]
                                then
					echo "please set the password of below users".
					echo -e "${red}"
                                        echo $j
                                fi
                        done
			echo -e "${NC}"
                done
        fi
done


##check No Non-Root Accounts have uid 0
op=`/bin/cat /etc/passwd | grep x:0 | wc -l`
if [ $op -eq 1 ]
then
        echo -e "No, Non-Root accounts have UID 0. ${green} It's looking cool!! ${NC}"
else 
        echo "Please check your /etc/passwd. You are having some Non-Root user that are having uid 0."
	  echo -e "please find the usernames below that are having uid 0: ${red}"
          /bin/cat /etc/passwd | grep x:0 | awk -F":" '{print $1}'
	echo -e "${NC}"

fi

##check permission on file
ponfile=`ls -l /etc/passwd |awk  '{print $1}' | awk -F"." '{print $1}'`
if [ $ponfile == "-rw-r--r--" ]
then
	echo "Permission on passwd file is fine."
else 
	echo "Please check permission on /etc/passwd."
fi

ponfile1=`ls -l /etc/group |awk  '{print $1}' | awk -F"." '{print $1}'`
if [ $ponfile1 == "-rw-r--r--" ]
then
	echo "Permission on group file is fine."
else 
	echo "Please check permission on /etc/group."
fi

ponfile2=`ls -l /etc/shadow |awk  '{print $1}' | awk -F"." '{print $1}'`
if [ $ponfile2 == "----------" ]
then
	echo "Permission on shadow file is fine."
else 
	echo "Please check permission on /etc/shadow."
fi

ponfile3=`ls -l /etc/gshadow |awk  '{print $1}' | awk -F"." '{print $1}'`
if [ $ponfile3 == "----------" ]
then
	echo "Permission on gshadow file is fine."
else 
	echo "Please check permission on /etc/gshadow."
fi
##


