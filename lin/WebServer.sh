#!/bin/bash
#This installs an apache server and self signs it to enable HTTPS
#A mariaDB/mySQL database is created to enable login script via .php
#DNS is bind9 to it self to host its own domain and tld, forwards to 8.8.8.8 for normal network connections
#FTP is slooply setup to the standards of this company (anonymous is enabled)
#cat, wget, systemctl, cp, rm, sed, ufw, service, openssl, echo, mkdir, base64
#todo: full pathing to each, sure they exist#

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
if [ "$1" ]
then
FQDN=$1
else
read -p 'Domain name (domain.tld) ' FQDN
fi
if [[ $FQDN != *"."* ]]
then
echo "Domain must have a domain name, a .(dot) and a top level domain"
exit
fi
if [ ! -d /dev/shm ]
then
echo "/dev/shm is needed for this, please make or unlock it"
exit
fi
IPADDRESS=$(hostname -I | head -n1 | awk '{print $1}')
apt-get update -y; apt-get full-upgrade -y; apt-get autoremove -y
apt-get install apache2 mariadb-server php7.2 php-mysql bind9 libapache2-mod-php vsftpd wget -y
if [[ $? > 0 ]]
then
    echo "Failed to download/install a package, please try again."
    exit
else
    echo "The apt ran succesfuly, continuing with script."
fi
##Up setting DB and HTML/PHP
#https://mariadb.com/kb/en/documentation/
mysql_secure_installation << EOF
qwe
n
y
n
y
y
EOF
mysql << EOF
CREATE USER 'WebAdmin'@'localhost' IDENTIFIED BY 'asdasd';
GRANT ALL PRIVILEGES ON * . * TO 'WebAdmin'@'localhost';
FLUSH PRIVILEGES;
CREATE DATABASE WebUsers;
USE WebUsers;
CREATE TABLE users ( id int(11) unsigned NOT NULL AUTO_INCREMENT, email varchar(250) NOT NULL DEFAULT '', password varchar(200) NOT NULL DEFAULT '', primary key (id))ENGINE=InnoDB DEFAULT CHARSET=utf8;LOCK TABLES `users` WRITE;
UNLOCK TABLES;
EXIT;
EOF

#https://www.youtube.com/watch?v=bjT5PJn0Mu8
mkdir /var/www/$FQDN
mkdir /var/www/$FQDN/assets/css -p
URL=$(echo $FQDN | sed 's/\./%20/g')
URLS=$(wget "https://www.bing.com/images/search?q=$URL" -O- | sed 's/></>\n</g' | grep "<a class=\"thumb\" target=\"_blank\" href=\"" | sed 's/.*http/http/g' | sed 's/" h=.*//g' | head -n3)
wget $(echo $URLS | awk '{print $1}') -O /var/www/$FQDN/assets/img.1
wget $(echo $URLS | awk '{print $2}') -O /var/www/$FQDN/assets/img.2
wget $(echo $URLS | awk '{print $3}') -O /var/www/$FQDN/assets/img.3

echo PD9waHANCg0Kc2Vzc2lvbl9zdGFydCgpOw0KDQpyZXF1aXJlICdkYXRhYmFzZS5waHAnOw0KDQppZiggaXNzZXQoJF9TRVNTSU9OWyd1c2VyX2lkJ10pICl7DQoNCgkkcmVjb3JkcyA9ICRjb25uLT5wcmVwYXJlKCdTRUxFQ1QgaWQsZW1haWwscGFzc3dvcmQgRlJPTSB1c2VycyBXSEVSRSBpZCA9IDppZCcpOw0KCSRyZWNvcmRzLT5iaW5kUGFyYW0oJzppZCcsICRfU0VTU0lPTlsndXNlcl9pZCddKTsNCgkkcmVjb3Jkcy0+ZXhlY3V0ZSgpOw0KCSRyZXN1bHRzID0gJHJlY29yZHMtPmZldGNoKFBETzo6RkVUQ0hfQVNTT0MpOw0KDQoJJHVzZXIgPSBOVUxMOw0KDQoJaWYoIGNvdW50KCRyZXN1bHRzKSA+IDApew0KCQkkdXNlciA9ICRyZXN1bHRzOw0KCX0NCg0KfQ0KDQo/Pg0KDQo8IURPQ1RZUEUgaHRtbD4NCjxodG1sPg0KPGhlYWQ+DQoJPHRpdGxlPlNlY3VyZSBXZWJzaXRlPC90aXRsZT4NCgk8bGluayByZWw9InN0eWxlc2hlZXQiIHR5cGU9InRleHQvY3NzIiBocmVmPSJhc3NldHMvY3NzL3N0eWxlLmNzcyI+DQoJPGxpbmsgaHJlZj0naHR0cDovL2ZvbnRzLmdvb2dsZWFwaXMuY29tL2Nzcz9mYW1pbHk9Q29tZm9ydGFhJyByZWw9J3N0eWxlc2hlZXQnIHR5cGU9J3RleHQvY3NzJz4NCjwvaGVhZD4NCjxib2R5Pg0KDQoJPGRpdiBjbGFzcz0iaGVhZGVyIj4NCgkJPGEgaHJlZj0iLyI+U2VjdXJlIFNpdGU8L2E+DQoJPC9kaXY+DQoNCgk8P3BocCBpZiggIWVtcHR5KCR1c2VyKSApOiA/Pg0KDQoJCTxiciAvPldlbGNvbWUgPD89ICR1c2VyWydlbWFpbCddOyA/PiANCgkJPGJyIC8+PGJyIC8+WW91IGFyZSBzdWNjZXNzZnVsbHkgbG9nZ2VkIGluIQ0KCQk8YnIgLz48YnIgLz4NCgkJPGEgaHJlZj0ibG9nb3V0LnBocCI+TG9nb3V0PzwvYT4NCg0KCTw/cGhwIGVsc2U6ID8+DQoNCgkJPGgxPlBsZWFzZSBMb2dpbiBvciBSZWdpc3RlcjwvaDE+DQoJCTxhIGhyZWY9ImxvZ2luLnBocCI+TG9naW48L2E+IG9yDQoJCTxhIGhyZWY9InJlZ2lzdGVyLnBocCI+UmVnaXN0ZXI8L2E+DQoNCgk8P3BocCBlbmRpZjsgPz4NCjxicj48YnI+DQo8aW1nIHNyYz0iYXNzZXRzL2ltZy4xIj4NCjxpbWcgc3JjPSJhc3NldHMvaW1nLjIiPg0KPGltZyBzcmM9ImFzc2V0cy9pbWcuMyI+DQo8L2JvZHk+DQo8L2h0bWw+ | base64 -d > /var/www/$FQDN/index.php

echo PD9waHANCg0Kc2Vzc2lvbl9zdGFydCgpOw0KDQppZiggaXNzZXQoJF9TRVNTSU9OWyd1c2VyX2lkJ10pICl7DQoJaGVhZGVyKCJMb2NhdGlvbjogLyIpOw0KfQ0KDQpyZXF1aXJlICdkYXRhYmFzZS5waHAnOw0KDQppZighZW1wdHkoJF9QT1NUWydlbWFpbCddKSAmJiAhZW1wdHkoJF9QT1NUWydwYXNzd29yZCddKSk6DQoJDQoJJHJlY29yZHMgPSAkY29ubi0+cHJlcGFyZSgnU0VMRUNUIGlkLGVtYWlsLHBhc3N3b3JkIEZST00gdXNlcnMgV0hFUkUgZW1haWwgPSA6ZW1haWwnKTsNCgkkcmVjb3Jkcy0+YmluZFBhcmFtKCc6ZW1haWwnLCAkX1BPU1RbJ2VtYWlsJ10pOw0KCSRyZWNvcmRzLT5leGVjdXRlKCk7DQoJJHJlc3VsdHMgPSAkcmVjb3Jkcy0+ZmV0Y2goUERPOjpGRVRDSF9BU1NPQyk7DQoNCgkkbWVzc2FnZSA9ICcnOw0KDQoJaWYoY291bnQoJHJlc3VsdHMpID4gMCAmJiBwYXNzd29yZF92ZXJpZnkoJF9QT1NUWydwYXNzd29yZCddLCAkcmVzdWx0c1sncGFzc3dvcmQnXSkgKXsNCg0KCQkkX1NFU1NJT05bJ3VzZXJfaWQnXSA9ICRyZXN1bHRzWydpZCddOw0KCQloZWFkZXIoIkxvY2F0aW9uOiAvIik7DQoNCgl9IGVsc2Ugew0KCQkkbWVzc2FnZSA9ICdTb3JyeSwgdGhvc2UgY3JlZGVudGlhbHMgZG8gbm90IG1hdGNoJzsNCgl9DQoNCmVuZGlmOw0KDQo/Pg0KDQo8IURPQ1RZUEUgaHRtbD4NCjxodG1sPg0KPGhlYWQ+DQoJPHRpdGxlPlNlY3VyZSBMb2dpbjwvdGl0bGU+DQoJPGxpbmsgcmVsPSJzdHlsZXNoZWV0IiB0eXBlPSJ0ZXh0L2NzcyIgaHJlZj0iYXNzZXRzL2Nzcy9zdHlsZS5jc3MiPg0KCTxsaW5rIGhyZWY9J2h0dHA6Ly9mb250cy5nb29nbGVhcGlzLmNvbS9jc3M/ZmFtaWx5PUNvbWZvcnRhYScgcmVsPSdzdHlsZXNoZWV0JyB0eXBlPSd0ZXh0L2Nzcyc+DQo8L2hlYWQ+DQo8Ym9keT4NCg0KCTxkaXYgY2xhc3M9ImhlYWRlciI+DQoJCTxhIGhyZWY9Ii8iPlNlY3VyZSBTaXRlPC9hPg0KCTwvZGl2Pg0KDQoJPD9waHAgaWYoIWVtcHR5KCRtZXNzYWdlKSk6ID8+DQoJCTxwPjw/PSAkbWVzc2FnZSA/PjwvcD4NCgk8P3BocCBlbmRpZjsgPz4NCg0KCTxoMT5Mb2dpbjwvaDE+DQoJPHNwYW4+b3IgPGEgaHJlZj0icmVnaXN0ZXIucGhwIj5yZWdpc3RlciBoZXJlPC9hPjwvc3Bhbj4NCg0KCTxmb3JtIGFjdGlvbj0ibG9naW4ucGhwIiBtZXRob2Q9IlBPU1QiPg0KCQkNCgkJPGlucHV0IHR5cGU9InRleHQiIHBsYWNlaG9sZGVyPSJFbnRlciB5b3VyIGVtYWlsIiBuYW1lPSJlbWFpbCI+DQoJCTxpbnB1dCB0eXBlPSJwYXNzd29yZCIgcGxhY2Vob2xkZXI9ImFuZCBwYXNzd29yZCIgbmFtZT0icGFzc3dvcmQiPg0KDQoJCTxpbnB1dCB0eXBlPSJzdWJtaXQiPg0KDQoJPC9mb3JtPg0KDQo8L2JvZHk+DQo8L2h0bWw+| base64 -d > /var/www/$FQDN/login.php

echo PD9waHANCiRzZXJ2ZXIgPSAnbG9jYWxob3N0JzsNCiR1c2VybmFtZSA9ICdXZWJBZG1pbic7DQokcGFzc3dvcmQgPSAnYXNkYXNkJzsNCiRkYXRhYmFzZSA9ICdXZWJVc2Vycyc7DQoNCnRyeXsNCgkkY29ubiA9IG5ldyBQRE8oIm15c3FsOmhvc3Q9JHNlcnZlcjtkYm5hbWU9JGRhdGFiYXNlOyIsICR1c2VybmFtZSwgJHBhc3N3b3JkKTsNCn0gY2F0Y2goUERPRXhjZXB0aW9uICRlKXsNCglkaWUoICJDb25uZWN0aW9uIGZhaWxlZDogIiAuICRlLT5nZXRNZXNzYWdlKCkpOw0KfQ | base64 -d > /var/www/$FQDN/database.php

echo PD9waHANCg0Kc2Vzc2lvbl9zdGFydCgpOw0KDQpzZXNzaW9uX3Vuc2V0KCk7DQoNCnNlc3Npb25fZGVzdHJveSgpOw0KDQpoZWFkZXIoIkxvY2F0aW9uOiAvIik7 | base64 -d > /var/www/$FQDN/logout.php

echo PD9waHANCg0Kc2Vzc2lvbl9zdGFydCgpOw0KDQppZiggaXNzZXQoJF9TRVNTSU9OWyd1c2VyX2lkJ10pICl7DQoJaGVhZGVyKCJMb2NhdGlvbjogLyIpOw0KfQ0KDQpyZXF1aXJlICdkYXRhYmFzZS5waHAnOw0KDQokbWVzc2FnZSA9ICcnOw0KDQppZighZW1wdHkoJF9QT1NUWydlbWFpbCddKSAmJiAhZW1wdHkoJF9QT1NUWydwYXNzd29yZCddKSk6DQoJDQoJLy8gRW50ZXIgdGhlIG5ldyB1c2VyIGluIHRoZSBkYXRhYmFzZQ0KCSRzcWwgPSAiSU5TRVJUIElOVE8gdXNlcnMgKGVtYWlsLCBwYXNzd29yZCkgVkFMVUVTICg6ZW1haWwsIDpwYXNzd29yZCkiOw0KCSRzdG10ID0gJGNvbm4tPnByZXBhcmUoJHNxbCk7DQoNCgkkc3RtdC0+YmluZFBhcmFtKCc6ZW1haWwnLCAkX1BPU1RbJ2VtYWlsJ10pOw0KCSRzdG10LT5iaW5kUGFyYW0oJzpwYXNzd29yZCcsIHBhc3N3b3JkX2hhc2goJF9QT1NUWydwYXNzd29yZCddLCBQQVNTV09SRF9CQ1JZUFQpKTsNCg0KCWlmKCAkc3RtdC0+ZXhlY3V0ZSgpICk6DQoJCSRtZXNzYWdlID0gJ1N1Y2Nlc3NmdWxseSBjcmVhdGVkIG5ldyB1c2VyJzsNCgllbHNlOg0KCQkkbWVzc2FnZSA9ICdTb3JyeSB0aGVyZSBtdXN0IGhhdmUgYmVlbiBhbiBpc3N1ZSBjcmVhdGluZyB5b3VyIGFjY291bnQnOw0KCWVuZGlmOw0KDQplbmRpZjsNCg0KPz4NCg0KPCFET0NUWVBFIGh0bWw+DQo8aHRtbD4NCjxoZWFkPg0KCTx0aXRsZT5TZWN1cmUgUmVnaXN0ZXI8L3RpdGxlPg0KCTxsaW5rIHJlbD0ic3R5bGVzaGVldCIgdHlwZT0idGV4dC9jc3MiIGhyZWY9ImFzc2V0cy9jc3Mvc3R5bGUuY3NzIj4NCgk8bGluayBocmVmPSdodHRwOi8vZm9udHMuZ29vZ2xlYXBpcy5jb20vY3NzP2ZhbWlseT1Db21mb3J0YWEnIHJlbD0nc3R5bGVzaGVldCcgdHlwZT0ndGV4dC9jc3MnPg0KPC9oZWFkPg0KPGJvZHk+DQoNCgk8ZGl2IGNsYXNzPSJoZWFkZXIiPg0KCQk8YSBocmVmPSIvIj5TZWN1cmUgU2l0ZTwvYT4NCgk8L2Rpdj4NCg0KCTw/cGhwIGlmKCFlbXB0eSgkbWVzc2FnZSkpOiA/Pg0KCQk8cD48Pz0gJG1lc3NhZ2UgPz48L3A+DQoJPD9waHAgZW5kaWY7ID8+DQoNCgk8aDE+UmVnaXN0ZXI8L2gxPg0KCTxzcGFuPm9yIDxhIGhyZWY9ImxvZ2luLnBocCI+bG9naW4gaGVyZTwvYT48L3NwYW4+DQoNCgk8Zm9ybSBhY3Rpb249InJlZ2lzdGVyLnBocCIgbWV0aG9kPSJQT1NUIj4NCgkJDQoJCTxpbnB1dCB0eXBlPSJ0ZXh0IiBwbGFjZWhvbGRlcj0iRW50ZXIgeW91ciBlbWFpbCIgbmFtZT0iZW1haWwiPg0KCQk8aW5wdXQgdHlwZT0icGFzc3dvcmQiIHBsYWNlaG9sZGVyPSJhbmQgcGFzc3dvcmQiIG5hbWU9InBhc3N3b3JkIj4NCgkJPGlucHV0IHR5cGU9InBhc3N3b3JkIiBwbGFjZWhvbGRlcj0iY29uZmlybSBwYXNzd29yZCIgbmFtZT0iY29uZmlybV9wYXNzd29yZCI+DQoJCTxpbnB1dCB0eXBlPSJzdWJtaXQiPg0KDQoJPC9mb3JtPg0KDQo8L2JvZHk+DQo8L2h0bWw+ | base64 -d > /var/www/$FQDN/register.php

echo Ym9keXsNCgltYXJnaW46MHB4Ow0KCXBhZGRpbmc6MHB4Ow0KCWZvbnQtZmFtaWx5OiAnQ29tZm9ydGFhJywgY3Vyc2l2ZTsNCgl0ZXh0LWFsaWduOmNlbnRlcjsNCn0NCg0KaW5wdXRbdHlwZT0idGV4dCJdLCBpbnB1dFt0eXBlPSJwYXNzd29yZCJdew0KCW91dGxpbmU6bm9uZTsNCglwYWRkaW5nOjEwcHg7DQoJZGlzcGxheTpibG9jazsNCgl3aWR0aDozMDBweDsNCglib3JkZXItcmFkaXVzOiAzcHg7DQoJYm9yZGVyOjFweCBzb2xpZCAjZWVlOw0KCW1hcmdpbjoyMHB4IGF1dG87DQp9DQoNCmlucHV0W3R5cGU9InN1Ym1pdCJdew0KCXBhZGRpbmc6MTBweDsNCgljb2xvcjojZmZmOw0KCWJhY2tncm91bmQ6IzAwOThjYjsNCgl3aWR0aDozMjBweDsNCgltYXJnaW46MjBweCBhdXRvOw0KCW1hcmdpbi10b3A6MHB4Ow0KCWJvcmRlcjowcHg7DQoJYm9yZGVyLXJhZGl1czogM3B4Ow0KCWN1cnNvcjpwb2ludGVyOw0KfQ0KDQppbnB1dFt0eXBlPSJzdWJtaXQiXTpob3ZlcnsNCgliYWNrZ3JvdW5kOiMwMGI4ZWI7DQp9DQoNCi5oZWFkZXJ7DQoJYm9yZGVyLWJvdHRvbToxcHggc29saWQgI2VlZTsNCglwYWRkaW5nOjEwcHggMHB4Ow0KCXdpZHRoOjEwMCU7DQoJdGV4dC1hbGlnbjpjZW50ZXI7DQp9DQoNCi5oZWFkZXIgYXsNCgljb2xvcjojMzMzOw0KCXRleHQtZGVjb3JhdGlvbjogbm9uZTsNCn0 | base64 -d > /var/www/$FQDN/assets/css/style.css


##Up setting HTTPS and DNS
#https://www.stackovercloud.com/2020/07/07/how-to-create-a-self-signed-ssl-certificate-for-apache-in-ubuntu-20-04/
a2enmod php7.2 ssl
systemctl restart apache2
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt << EOF
DK
Denmark
Zealand
ZBC
Data
$FQDN
mail@$FQDN
EOF
cat << EOF > /etc/apache2/sites-available/$FQDN.conf
<VirtualHost *:80>
    ServerName $FQDN
    Redirect / https://$FQDN/
</VirtualHost>
<VirtualHost *:443>
   ServerName $FQDN
   DocumentRoot /var/www/$FQDN

   SSLEngine on
   SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
   SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>
EOF
a2ensite $FQDN
systemctl reload apache2
ufw allow "Apache Full"

#https://www.itsmarttricks.com/how-to-configure-slave-dns-server-with-bind-secondary-dns-server-in-linux/
#https://www.computernetworkingnotes.com/rhce-study-guide/how-to-configure-dns-server-in-linux.html
cat /etc/bind/named.conf.options | sed 's-//.*0.0.0.0- 8.8.8.8-g' | sed 's-// fo- fo-g' | sed 's-// };- };-g' >> /dev/shm/named.conf.options.A
cp /dev/shm/named.conf.options.A /etc/bind/named.conf.options
rm /dev/shm/named.conf.options.A
service bind9 restart
sed -i "s/127.0.0.53/127.0.0.1/g" /etc/resolv.conf
cat << EOF >> /etc/bind/named.conf.local
zone "$FQDN" {
    type master;
    file "/etc/bind/db.$FQDN";
};
zone "0.42.10.in-addr.arpa" {
        type master;
        notify no;
        file "/etc/bind/db.10";
};
EOF
cp /etc/bind/db.local /etc/bind/db.$FQDN
cat /etc/bind/db.$FQDN | sed "s/localhost/$FQDN/g" | sed "s/root.$FQDN/root.localhost/g" >> /dev/shm/db.$FQDN.A
cp /dev/shm/db.$FQDN.A /etc/bind/db.$FQDN
rm /dev/shm/db.$FQDN.A
cat << EOF >> /etc/bind/db.$FQDN
$FQDN. IN MX 10 mail.$FQDN.
ns IN A $IPADDRESS
web IN A $IPADDRESS
mail IN A $IPADDRESS
EOF
cp /etc/bind/db.127 /etc/bind/db.10
sed -i "s/SOA\tlocalhost/SOA\t$FQDN/g" /etc/bind/db.10
cat << EOF >> /etc/bind/db.10
83 IN PTR ns.$FQDN.
70 IN PTR mail.$FQDN.
80 in PRT web.$FQDN.
EOF

##Up setting FTP with login and anonymous login
#https://www.wikihow.com/Set-up-an-FTP-Server-in-Ubuntu-Linux
sed -i 's/#local_enable/local_enable/g' /etc/vsftpd.conf
sed -i 's/anonymous_enable=NO/anonymous_enable=YES/g' /etc/vsftpd.conf
sed -i 's/#ls_recurse_enable=YES/ls_recurse_enable=YES/g' /etc/vsftpd.conf
sed -i "s/#ftpd_banner=Welcome to blah FTP service./ftpd_banner=Welcome to $FQDN FTP service/g" /etc/vsftpd.conf
mkdir -p /var/ftp/$FQDN/anon
echo "anon_root=/var/ftp/$FQDN/anon" >> /etc/vsftpd.conf

##Restartin services to make sure configs are set and running
service vsftpd restart
service apache2 restart
service bind9 restart
service mariadb restart


echo "you can now visit your site at http://"$FQDN
echo "or ftp to $IPADDRESS with anonymous or any local users"
exit 0
