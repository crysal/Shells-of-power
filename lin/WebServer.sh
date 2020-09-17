#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
read -p 'Domain name (domain.tld) ' FQDN 
IPADDRESS=$(hostname -I | head -n1 | awk '{print $1}')
apt-get update -y; apt-get full-upgrade -y; apt-get autoremove -y
apt-get install apache2 mariadb-server php7.2 bind9 libapache2-mod-php vsftpd -y

##Up setting DB and HTML/PHP

mysql_secure_installation << EOF
qwe
n
y
n
y
y
EOF
mysql << EOF
CREATE DATABASE WebUsers;
USE WebUsers;
CREATE TABLE users ( username VARCHAR(64), password VARCHAR(101), privilege VARCHAR(64));
INSERT INTO users (username, password, privilege) values ("admin", "qwe", "0");
EXIT;
EOF

mkdir /var/www/$FQDN
cat << EOF > /var/www/$FQDN/index.html
<html><head><title>Secure site</title></head><body><h1>Welcome to a very secure site.</h1><a href="login.php">Login</a></body></html>
EOF
cat << EOF > /var/www/$FQDN/login.php
<?php;
try{\$conn = mysqli_connect(localhost, root, qwe, WebUser);
if (!\$conn) {die("Connection failed: " . mysqli_connect_error());};
\$user = "SELECT username FROM users";
\$urs0 = mysqli_query(\$conn, \$sql);
\$pass = "SELECT password FROM users";
\$pas0 = mysqli_query(\$conn, \$sql);
if(!empty(\$_POST['username']) && !empty(\$_POST['password'])){
if((\$_POST['username'] = "\$usr0") && (\$POST['password'] = "\$pas0")){header('Location: '.loggedin.php);};};?>
<!DOCTYPE html>
<html>
<head>
<title>Login</title>
</head>
<body><h1>Login</h1>
<form action="login.php" method="POST">
<input type="text" placeholder="Enter username" name="username">
<input type="text" placeholder="Enter password" name="password">
<input type="submit"></form></body></html>
EOF
cat << EOF > /var/www/$FQDN/loggedin.php
<h1>logged in</h1>
EOF


##Up setting HTTPS and DNS

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
service bind9 restart

##Up setting FTP with login and anonymous login

sed -i 's/#local_enable/local_enable/g' /etc/vsftpd.conf
sed -i 's/anonymous_enable=NO/anonymous_enable=YES/g' /etc/vsftpd.conf
sed -i 's/#ls_recurse_enable=YES/ls_recurse_enable=YES/g' /etc/vsftpd.conf
mkdir -p /var/ftp/$FQDN/anon
echo "anon_root=/var/ftp/$FQDN/anon" >> /etc/vsftpd.conf

service vsftpd restart

echo "you can now visit your site at http://"$FQDN
