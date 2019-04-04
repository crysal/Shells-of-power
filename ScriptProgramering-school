#!/bin/bash

#hvis du vil vide hvad du kan
if [ "$1" == "-?" ] || [ "$1" == "--help" ]
then
cat <<\HELP
Script usage: ./script (-a, --auto (-ip)) (-?, --help)
-a, --auto (-ip)
     Sets the script to never ask for user input. Usernames and passwords will be set to $RANDOM
     Usernames, passwords and IPs are printet in plaintext into the /var/log/ScriptLog file.
	   if '-ip' is set you will have to type the IPs you want else it will set as random between 001-255
	 

-?, --help
     Shows this page
HELP
exit 0
fi

#En function til at centrere text
function centerme {
tput cup $(tput lines) $(($(($(tput cols) / 2))-$((${#1} / 2))))
echo -e "$2$1$3"
} #centerme $TXT $ColorCode $ColorcodeEnd [Remember to use 2 \ infort of color code] \\e[31m \\e[0m

function karkter
{
cat <<\EOF
 ___     _____   
(_  |   /  _  \  
  | |  (___)| |  
  | |       / /  
  | |      / /   
  | |     / /    
  | |    / /     
  | |   / /____  
 (___) (_______) 
EOF
sleep 0.05
clear
}

#starter på header
#laver en function til headern så der kan kaleds på den senere i secripted uden af den skal fylde så meget
function TheWord {
echo -e "\e[31m"
cat <<\PHEONIX
                            .-==========                          
                         .-' O    =====                           
                        /___       ===                            
                           \_                                     
_____________________________)    (_____________________________  
\___________               .'      \`,              ____________/ 
  \__________`.     |||<   `.      .'   >|||     .'__________/    
     \_________`._  |||  <   `-..-'   >  |||  _.'_________/       
        \_________`-..|_  _ <      > _  _|..-'_________/          
           \_________   |_|  //  \\  |_|   _________/             
                      .-\   //    \\   /-.                        
                   _.'.- `._        _.' -.`._                     
                 .' .'  /  '``----''`  \  `. `.                   
                   /  .' .'.'/|12|\`.`. `.  \                     
                  `  /  / .'| |||| |`. \  \  '                    
                   ::_.' .' /| || |\ `. `._::                     
                     '``.' | | || | | `.''`                       
                       .` .` | || | '. '.                         
                          `  | `' |  '                            
PHEONIX

centerme "Copyright (c) 2019 - Lukas Hoffmann(Crysal)" "\\e[34m" "\\e[0m"
centerme "The script is made for instllation of LAMP and more" "\\e[34m" "\\e[0m"
centerme "Start date: 01-04-2019 09:57" "\\e[34m" "\\e[0m"
centerme "Log file stored at /var/log/ScriptLog" "\\e[34m" "\\e[0m"
centerme "https://github.com/crysal0/Shells-of-power/blob/master/ScriptProgramering-school" "\\e[34m" "\\e[0m"

}
#Kalder på den header vi liger har lavet for at få det vist som det første
TheWord
sleep 5
#Slut på header

#reboot checker
if [ ! -f /rebootchecker ] ; then #reboot if
WhereAmI="$(pwd)/`basename "$0"`" #tager navnet på den script som der køres og stien
echo "bash $WhereAmI" >> ~/.bashrc 


#kan sætte -a, --auto til at den køre uden user input
if [ "$1" == "-a" ] || [ "$1" == "--auto" ]
then
autocheck=true
centerme "Auto is set" "\\e[90m" "\\e[0m"
shift
else
autocheck=false
centerme "Manual is set" "\\e[90m" "\\e[0m"
fi


#starter med at ligge en log med hvornår scriptet er started i log filen /var/log/ScriptLog
#Alle yum kommandoer har et pipe tee på til at putte errors i loggen
echo -e "\n                    $me was started $(date)" >> /var/log/ScriptLog


#her opdatager man så man er sikker på at maskinen er klar til at køre installationer
centerme "Checking for updates" "\\e[0m" "\\e[31m"
echo -e "\n                              CHECKING FOR UPDATES\n" >> /var/log/ScriptLog
#en yum som køre uden noget output, der kommer kun output hvis der er nogle errors ved level 0, dette bliver lagt i log fil.. Det køres på alle yum i scripted
yum update --assumeyes --quiet --errorlevel=0 | tee --append /var/log/ScriptLog


#tilføjer PHP 7.3 reposotory og fjerner 5.4 reposotory
centerme "Configuring PHP Repsotorys" "\\e[0m" "\\e[31m"
echo -e "\n                              ADDINIG PHP7.3 REPOSOTORY\n" >> /var/log/ScriptLog
yum install epel-release yum-utils --assumeyes --quiet --errorlevel=0 | tee --append /var/log/ScriptLog
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm --assumeyes --quiet --errorlevel=0 | tee --append /var/log/ScriptLog
echo -e "\n                              RREMOVING PHP5.4 REPOSOTORY\n" >> /var/log/ScriptLog
yum-config-manager --disable remi-php54 >> /var/log/ScriptLog
yum-config-manager --enable remi-php73 >> /var/log/ScriptLog


#install Apache/ PHP 7.3
centerme "Installing Apache/ PHP 7.3" "\\e[0m" "\\e[31m"
echo -e "\n                              INSTALLING APACHE/PHP7.3\n" >> /var/log/ScriptLog
yum install httpd php php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json --assumeyes --quiet --errorlevel=0  | tee --append /var/log/ScriptLog
echo "<?php
phpinfo();
?>" > /var/www/html/info.php
systemctl enable httpd


#install MariaDB and configuring
centerme "Installing MariaDB" "\\e[0m" "\\e[31m"
echo -e "\n                              INSTALLING MARIADB\n" >> /var/log/ScriptLog
yum install mariadb-server mariadb --assumeyes --quiet --errorlevel=0 | tee --append /var/log/ScriptLog
systemctl start mariadb >> /var/log/ScriptLog
systemctl enable mariadb >> /var/log/ScriptLog

# tjekker om sæt til automatisk
if $autocheck ; then
centerme "Auto is set" "\\e[90m" "\\e[31m"
centerme "Outputting credentials to /var/log/ScriptLog" "\\e[32m" "\\e[31m"
#generare random username og passwords på en længde   V   af 8
DBPASS=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 8 | head -n 1)
DBNAME1=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 8 | head -n 1)
DBNAME2=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 8 | head -n 1)
DBUSER1=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 8 | head -n 1)
DBUSER2=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 8 | head -n 1)
DBUSERPASS1=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 8 | head -n 1)
DBUSERPASS2=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 8 | head -n 1)
#outputter de random ting til /var/log/ScriptLog
echo "MYSQL CREDENTIALS" >> /var/log/ScriptLog
echo "Root password: $DBPASS" >> /var/log/ScriptLog
echo "1st Database name: $DBNAME1" >> /var/log/ScriptLog
echo "2nd Database name: $DBNAME2" >> /var/log/ScriptLog
echo "1st Username: $DBUSER1" >> /var/log/ScriptLog
echo "2nd Username: $DBUSER2" >> /var/log/ScriptLog
echo "1st User Password: $DBUSERPASS1" >> /var/log/ScriptLog
echo "2nd User Password: $DBUSERPASS2" >> /var/log/ScriptLog
else
#Spørg brugeren efter usernames og passwords og database navne
echo -e "\e[0m"
read -s -p "New database root password: " DBPASS
echo
read -p "New database name1: " DBNAME1
read -p "New database name2: " DBNAME2
read -p "New database user1: " DBUSER1
read -p "New database user2: " DBUSER2
read -s -p "New database user1 password: " DBUSERPASS1
echo
read -s -p "New database user2 password: " DBUSERPASS2
echo -e "\e[31m"
fi


#køre mysql til at Secure_install og lave databases og bruger
mysql --execute "UPDATE mysql.user SET Password=PASSWORD('${DBPASS}') WHERE User='root';"
mysql --execute "DELETE FROM mysql.user WHERE User='';"
mysql --execute "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql --execute "DROP DATABASE IF EXISTS test;"
mysql --execute "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql --execute "CREATE DATABASE ${DBNAME1};"
mysql --execute "CREATE DATABASE ${DBNAME2};"
mysql --execute "CREATE USER '${DBUSER1}'@'localhost' IDENTIFIED BY '${DBUSERPASS1}';"
mysql --execute "CREATE USER '${DBUSER2}'@'localhost' IDENTIFIED BY '${DBUSERPASS2}';"
mysql --execute "GRANT ALL ON ${DBNAME1}.* TO '${DBUSER1}'@'localhost';"
mysql --execute "GRANT ALL ON ${DBNAME2}.* TO '${DBUSER2}'@'localhost';"
mysql --execute "FLUSH PRIVILEGES;"


#installere iptables
centerme "Installing Firewall" "\\e[0m" "\\e[31m"
echo -e "\n                              INSTALLING AND CONFIGURING IPTABLES-SERVICE\n" >> /var/log/ScriptLog
yum install iptables-service --assumeyes --quiet --errorlevel=0 | tee --append /var/log/ScriptLog
systemctl stop firewalld
systemctl mask firewalld >> /var/log/ScriptLog
#enabling http/https ports
iptables -A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT


#installing NTP and configuring NTP
centerme "Installing NTP" "\\e[0m" "\\e[31m"
echo -e "\n                              INSTALLING NTP\n" >> /var/log/ScriptLog
yum install ntp --assumeyes --quiet --errorlevel=0 | tee --append /var/log/ScriptLog
ntpdate 0.dk.pool.ntp.org >>  /var/log/ScriptLog
systemctl enable ntpd
systemctl start ntpd

#sætter static ip hvis auto er sat
if $autocheck ; then
if [ "$1" != "-ip" ] ; then
SIPipaddress=$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1 | tr -d 0).$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1 | tr -d 0).$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1 | tr -d 0).$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1)
SIPnetmask=$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1 | tr -d 0).$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1 | tr -d 0).$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1 | tr -d 0).$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1)
SIPgateway=$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1 | tr -d 0).$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1 | tr -d 0).$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1 | tr -d 0).$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1)
SIPdns1=$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1 | tr -d 0).$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1 | tr -d 0).$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1 | tr -d 0).$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1)
SIPdns2=$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1 | tr -d 0).$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1 | tr -d 0).$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1 | tr -d 0).$(cat /dev/urandom | tr -dc '0-2' | fold -w 1 | head -n 1 | tr -d 0)$(cat /dev/urandom | tr -dc '0-5' | fold -w 2 | head -n 1)
else
#hvis -ip er sat vil den spørge efter userinput til hvilke IP addresser du vil have
read -p "Input IP address: " SIPipaddress
read -p "Input Subnet Mask: " SIPnetmask
read -p "Input Default Gateway: " SIPgateway
read -p "Input Primary DNS: " SIPdns1
read -p "Input Secoundary DNS: " SIPdns2
fi
#finder hvilket ethernet kort du bruger og ligger den ind som en variable
ethernetcard=$(ip link show | grep 2: | head -n 1 | cut -c 4- | cut -d ":" -f1)
#afstatter dhcp med static så den ved det er en static IP
sed -i 's/BOOTPROTO="dhcp"/BOOTPROTO="static"/g' /etc/sysconfig/network-scripts/ifcfg-$ethernetcard
#sætter alt det data der blive ændret ind i loggen så hvis du har valgt auto kan du se hvilke IP du er blevet tildet
echo "
IPADDR=$SIPipaddress
NETMASK=$SIPnetmask
GATEWAY=$SIPgateway
DNS1=$SIPdns1
DNS2=$SIPdns2" >> /etc/sysconfig/network-scripts/ifcfg-$ethernetcard
echo "IPADDR=$SIPipaddress" >> /var/log/ScriptLog
echo "NETMASK=$SIPnetmask" >> /var/log/ScriptLog
echo "GATEWAY=$SIPgateway" >> /var/log/ScriptLog
echo "DNS1=$SIPdns1" >> /var/log/ScriptLog
echo "DNS2=$SIPdns2" >> /var/log/ScriptLog
fi

#Disable selinux
#Laver en variable som tjekker om selinux er Enforced eller Disabled
selinuxstatus=$(getenforce)
if [ "$selinuxstatus" != "Disabled" ] #checking if selinux is disabled to avoid having to restart every script
then
centerme "Destroying SELINUX" "\\e[0m" "\\e[31m"
echo -e "\n                              DISABLING SELINUX\n" >> /var/log/ScriptLog
#Erstatter alt efter = med disabled, i filen /etc/selinux/config
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
cat /etc/selinux/config >> /var/log/ScriptLog
#laver den fil som bliver tjekket på begyndelse af script
touch /rebootchecker
#hvis auto er sat til genstart med det samme
echo "Rebooting in 6 secounds becuse selinux has been disabled"
if $autocheck ; then
reboot
fi
#Kræver user confirmation for at genstarte
read -p "Please confirm by pressing enter"
sleep 1
echo "12"
sleep 0.5
echo "11"
sleep 0.5
echo "10"
sleep 0.5
echo "9"
sleep 0.5
echo "8"
sleep 0.5
echo "7"
sleep 0.5
echo "6"
sleep 0.5
echo "5"
sleep 0.5
echo "4"
sleep 0.5
echo "3"
sleep 0.5
echo "2"
sleep 0.5
echo "1"
sleep 0.5
echo -e "\e[30m\e[44mRebooting\e[0m"
sleep 1
karkter
reboot
fi

#starter her hvis den rebootchecker fil findes
else #reboot else
sed -i '$d' ~/.bashrc
rm -f /rebootchecker
fi #reboot fi

echo -e "This is the end of the script\e[0m" #end echo to put terminal back to default colors
exit 0
