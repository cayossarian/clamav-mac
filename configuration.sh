#!/bin/bash

#Maintainer : coldnfire
#Reporting bug : laboserver@gmail.com

# Find username
SW_USER=$(id -un 501)
SW_USER=$(echo $SW_USER | tr -d ' ')
SW_USER=$(echo $SW_USER | tr [:upper:] [:lower:]) ;
##########

# Buffer script
path=$(pwd)
##########

# Configuration folder, fix law
mkdir -p /var/log/clamav/ /var/lib/clamav/ /usr/local/var/run/clamav/ /var/jail/
chown -R clamav:clamav /opt/homebrew/etc/clamav /var/log/clamav/ /var/lib/clamav/ /usr/local/var/run/clamav/ 
chmod 700 /var/jail/
cd /var/lib/clamav/ && touch whitelist.ign2
cd /var/log/clamav/ && touch jail.log
cd /opt/homebrew/etc/clamav
cp freshclam.conf.sample freshclam.conf && cp clamd.conf.sample clamd.conf
##########

# Global program configuration
cd /usr/local/etc/clamav/ 
sed -ie 's/Example/#Example/g' clamd.conf
sed -ie "s/#LogFile \/tmp\/clamd.log/LogFile \/var\/log\/clamav\/clamd.log/g" clamd.conf
sed -ie 's/#LogFileMaxSize 2M/LogFileMaxSize 2M/g' clamd.conf
sed -ie 's/#LogTime yes/LogTime yes/g' clamd.conf
sed -ie 's/#LogVerbose yes/LogVerbose no/g' clamd.conf
sed -ie 's/#LogRotate yes/LogRotate yes/g' clamd.conf
sed -ie 's/#ExtendedDetectionInfo yes/ExtendedDetectionInfo yes/g' clamd.conf
sed -ie "s/#DatabaseDirectory \/var\/lib\/clamav/DatabaseDirectory \/var\/lib\/clamav/g" clamd.conf
sed -ie "s/#LocalSocket \/tmp\/clamd.socket/LocalSocket \/usr\/local\/var\/run\/clamd.sock/g" clamd.conf
sed -ie 's/#LocalSocketMode 660/LocalSocketMode 660/g' clamd.conf
sed -ie 's/#TCPSocket 3310/TCPSocket 3310/g' clamd.conf
sed -ie 's/#MaxThreads 20/MaxThreads 1/g' clamd.conf
sed -ie 's/#MaxDirectoryRecursion 20/MaxDirectoryRecursion 1/g' clamd.conf
sed -ie 's/#LogClean yes/LogClean no/g' clamd.conf

sed -ie 's/Example/#Example/g' freshclam.conf
sed -ie "s/#DatabaseDirectory \/var\/lib\/clamav/DatabaseDirectory \/var\/lib\/clamav/g" freshclam.conf
sed -ie "s/#UpdateLogFile \/var\/log\/freshclam.log/UpdateLogFile \/var\/log\/clamav\/freshclam.log/g" freshclam.conf
sed -ie 's/#LogFileMaxSize 2M/LogFileMaxSize 2M/g' freshclam.conf
sed -ie 's/#LogTime yes/LogTime yes/g' freshclam.conf
sed -ie 's/#LogVerbose yes/LogVerbose no/g' freshclam.conf
sed -ie 's/#LogRotate yes/LogRotate yes/g' freshclam.conf
sed -ie 's/#DatabaseOwner clamav/DatabaseOwner clamav/g' freshclam.conf
sed -ie 's/#Checks 24/Checks 3/g' freshclam.conf
##########

# Information mail for script
read -p "Inform address email for the SCRIPTS: " mail
##########

# Configuration clamav_rt.sh
mkdir -p /var/root/.clamav/
chown 700 /var/root/.clamav/

cd $path
sed -ie "s/user=/user=$SW_USER/g" clamav_rt.sh
sed -ie "s/folder=/folder=\/Users\/$SW_USER/g" clamav_rt.sh
sed -ie "s/email=/email=$mail/g" clamav_rt.sh
sed -ie "s/jail=/jail=\/var\/jail/g" clamav_rt.sh
cp clamav_rt.sh /var/root/.clamav/
chmod 700 clamav_rt.sh
##########

# Configuration clamav_cron.sh
sed -ie "s/user=/user=$SW_USER/g" clamav_cron.sh
sed -ie "s/folder=/folder=\/Users\/$SW_USER/g" clamav_cron.sh
sed -ie "s/email=/email=$mail/g" clamav_cron.sh
sed -ie "s/jail=/jail=\/var\/jail/g" clamav_cron.sh
cp clamav_cron.sh /var/root/.clamav/
chmod 700 clamav_cron.sh
##########

# Information Sender Mail
read -p "Inform sender email for POSTFIX : " mail

# Configuration postfix
cd /etc/postfix/ && touch sasl_passwd
chmod 600 sasl_passwd

read -p "Inform your relay host (for example gmail relay will be : smtp.gmail.com:587) : " relayhost
read -s -p "Inform the email sender POSTFIX password ? " sasl_passwd

relayhost="relayhost=$relayhost"
smtp_sasl_auth_enable="smtp_sasl_auth_enable=yes"
smtp_sasl_password_maps="smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd"
smtp_use_tls="smtp_use_tls=yes"
smtp_tls_security_level="smtp_tls_security_level=encrypt"
tls_random_source="tls_random_source=dev:/dev/urandom"
smtp_sasl_security_options="smtp_sasl_security_options=noanonymous"
smtp_always_send_ehlo="smtp_always_send_ehlo=yes"
smtp_sasl_mechanism_filter="smtp_sasl_mechanism_filter=plain"
sasl_password="$relayhost $mail:$sasl_passwd"

for i in $relayhost $smtp_sasl_auth_enable $smtp_sasl_password_maps $smtp_use_tls $smtp_tls_security_level $tls_random_source $smtp_sasl_security_options $smtp_always_send_ehlo $smtp_sasl_mechanism_filter 
do
   echo "$i" >> main.cf
done

echo "$sasl_password" >> sasl_passwd
sed -ie 's/relayhost=//g' sasl_passwd

postmap /etc/postfix/sasl_passwd
##########

#Configuration Daemon
cd $path
cp com.clamav_tr.plist /Library/LaunchDaemons/
cp com.clamav_cron.plist /Library/LaunchDaemons/
chmod 644 com.clamav_tr.plist
chmod 644 com.clamav_cron.plist

while [ "$yn" != "Yes" ]; do
        echo "Choose your type of installation"
        echo "1) Install Clamav Real Time"
        echo "2) Install Clamav Crontab"
        echo "3) Install Clamav Real Time and Clamav Crontab"
        echo "4) exit"

        read case;

        case $case in
        1) echo "You have entered : Clamav Real Time, is this correct ? (Yes or No)"

        read yn

        	launchctl load -w /Library/LaunchDaemons/com.clamav_tr.plist;;



        2) echo "You have entered : Install Clamav Crontab by Launchd, is this correct? (Yes or No)"

      read yn

                launchctl load -w /Library/LaunchDaemons/com.clamav_cron.plist;;



        3) echo "You have entered : install Clamav Crontab by Launchd and install Clamav Real Time, is this correct? (Yes or No)"

      read yn

                launchctl load -w /Library/LaunchDaemons/com.clamav_tr.plist
		launchctl load -w /Library/LaunchDaemons/com.clamav_cron.plist;;

        4) exit

    esac
done
##########

echo "Bye"
