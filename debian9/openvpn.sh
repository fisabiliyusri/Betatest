#!/bin/bash
#
# Original script by fornesia, rzengineer and fawzya
# Mod by SL
# ==================================================

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# update repository
apt update -y

# Install PHP 5.6
apt-get install sudo -y
usermod -aG sudo root

sudo apt -y install ca-certificates apt-transport-https
wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list

sudo apt update -y
sudo apt install php5.6 -y
sudo apt install php5.6-mcrypt php5.6-mysql php5.6-fpm php5.6-cli php5.6-common php5.6-curl php5.6-mbstring php5.6-mysqlnd php5.6-xml -y

# install webserver
cd
sudo apt-get -y install nginx
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/fisabiliyusri/sshsl/master/debian9/nginx-default.conf"
mkdir -p /home/vps/public_html
echo "<?php phpinfo() ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/fisabiliyusri/sshsl/master/debian9/vhost-nginx.conf"
/etc/init.d/nginx restart

# instal nginx php5.6 
apt-get -y install nginx php5.6-fpm
apt-get -y install nginx php5.6-cli
apt-get -y install nginx php5.6-mysql
apt-get -y install nginx php5.6-mcrypt
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/5.6/cli/php.ini

# cari config php fpm dengan perintah berikut "php --ini |grep Loaded"
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/5.6/cli/php.ini

# Cari config php fpm www.conf dengan perintah berikut "find / \( -iname "php.ini" -o -name "www.conf" \)"
sed -i 's/listen = \/run\/php\/php5.6-fpm.sock/listen = 127.0.0.1:9100/g' /etc/php/5.6/fpm/pool.d/www.conf
cd


# Edit port apache2 ke 8099
wget -O /etc/apache2/ports.conf "https://raw.githubusercontent.com/fisabiliyusri/sshsl/master/debian9/apache2.conf"

# Edit port virtualhost apache2 ke 8099
wget -O /etc/apache2/sites-enabled/000-default.conf "https://raw.githubusercontent.com/fisabiliyusri/sshsl/master/debian9/virtualhost.conf"

# restart apache2
/etc/init.d/apache2 restart

# Install OpenVPN dan Easy-RSA
apt install openvpn easy-rsa -y
apt install openssl iptables -y 

# copykan script generate Easy-RSA ke direktori OpenVPN
cp -r /usr/share/easy-rsa/ /etc/openvpn

# Buat direktori baru untuk easy-rsa keys
mkdir /etc/openvpn/easy-rsa/keys

# Kemudian edit file variabel easy-rsa
# nano /etc/openvpn/easy-rsa/vars
wget -O /etc/openvpn/easy-rsa/vars "https://raw.githubusercontent.com/fisabiliyusri/sshsl/master/debian9/vars.conf"
# edit projek export KEY_NAME="sl-vps"
# Save dan keluar dari editor

# generate Diffie hellman parameters
openssl dhparam -out /etc/openvpn/dh2048.pem 2048

# inialisasikan Public Key
cd /etc/openvpn/easy-rsa

# inialisasikan openssl.cnf
ln -s openssl-1.0.0.cnf openssl.cnf
echo "unique_subject = no" >> keys/index.txt.attr

# inialisasikan vars
. ./vars

# inialisasikan Public clean all
./clean-all

# Certificate Authority (CA)
./build-ca

# buat server key name yang telah kita buat sebelum nya yakni "sl-vps"
./build-key-server sl-vps

# generate ta.key
openvpn --genkey --secret keys/ta.key

# Buat config server UDP 2021
cd /etc/openvpn

cat > /etc/openvpn/server-udp-2021.conf <<-END
port 2021
proto udp
dev tun
ca easy-rsa/keys/ca.crt
cert easy-rsa/keys/sl-vps.crt
key easy-rsa/keys/sl-vps.key
dh dh2048.pem
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so login
client-cert-not-required
username-as-common-name
server 10.5.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 5 30
comp-lzo
persist-key
persist-tun
status server-udp-2021.log
verb 3
END

# Buat config server TCP 2021
cat > /etc/openvpn/server-tcp-2021.conf <<-END
port 2021
proto tcp
dev tun
ca easy-rsa/keys/ca.crt
cert easy-rsa/keys/sl-vps.crt
key easy-rsa/keys/sl-vps.key
dh dh2048.pem
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so login
client-cert-not-required
username-as-common-name
server 10.6.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 5 30
comp-lzo
persist-key
persist-tun
status server-tcp-2021.log
verb 3
END

# Buat config server UDP 2069
cat > /etc/openvpn/server-udp-2069.conf <<-END
port 2069
proto udp
dev tun
ca easy-rsa/keys/ca.crt
cert easy-rsa/keys/sl-vps.crt
key easy-rsa/keys/sl-vps.key
dh dh2048.pem
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so login
client-cert-not-required
username-as-common-name
server 10.7.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 5 30
comp-lzo
persist-key
persist-tun
status server-udp-2069.log
verb 3
END

# Buat config server TCP 2069
cat > /etc/openvpn/server-tcp-2069.conf <<-END
port 2069
proto tcp
dev tun
ca easy-rsa/keys/ca.crt
cert easy-rsa/keys/sl-vps.crt
key easy-rsa/keys/sl-vps.key
dh dh2048.pem
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so login
client-cert-not-required
username-as-common-name
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 5 30
comp-lzo
persist-key
persist-tun
status server-tcp-2200.log
verb 3
END

cd

cp /etc/openvpn/easy-rsa/keys/{sl-vps.crt,sl-vps.key,ca.crt,ta.key} /etc/openvpn
ls /etc/openvpn

# nano /etc/default/openvpn
sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn
# Cari pada baris #AUTOSTART=”all” hilangkan tanda pagar # didepannya sehingga menjadi AUTOSTART=”all”. Save dan keluar dari editor

# restart openvpn dan cek status openvpn
/etc/init.d/openvpn restart
/etc/init.d/openvpn status

# aktifkan ip4 forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
# edit file sysctl.conf
# nano /etc/sysctl.conf
# Uncomment hilangkan tanda pagar pada #net.ipv4.ip_forward=1

# Konfigurasi dan Setting untuk Client
mkdir clientconfig
cp /etc/openvpn/easy-rsa/keys/{sl-vps.crt,sl-vps.key,ca.crt,ta.key} clientconfig/
cd clientconfig

# Buat config client UDP 2021
cd /etc/openvpn
cat > /etc/openvpn/client-udp-2021.ovpn <<-END
##### Sulaiman L OpenVPN UDP #####
client
dev tun
proto udp
remote xxxxxxxxx 2021
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END

sed -i $MYIP2 /etc/openvpn/client-udp-2021.ovpn;

# Buat config client TCP 2021
cat > /etc/openvpn/client-tcp-2021.ovpn <<-END
##### Sulaiman L OpenVPN TCP #####
client
dev tun
proto tcp
remote xxxxxxxxx 2021
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END

sed -i $MYIP2 /etc/openvpn/client-tcp-2021.ovpn;

# Buat config client UDP 2069
cat > /etc/openvpn/client-udp-2069.ovpn <<-END
##### Sulaiman L OpenVPN UDP #####
client
dev tun
proto udp
remote xxxxxxxxx 2069
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END

sed -i $MYIP2 /etc/openvpn/client-udp-2069.ovpn;

# Buat config client TCP 2069
cat > /etc/openvpn/client-tcp-2069.ovpn <<-END
##### Sulaiman L OpenVPN TCP #####
client
dev tun
proto tcp
remote xxxxxxxxx 2069
##### Modification VPN #####
# http-proxy-retry #
# http-proxy xxxxxxxxx 3128 #
# http-proxy-option CUSTOM-HEADER Host google.com #
##### DONT FORGET TO SUPPORT US #####
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END

cd

sed -i $MYIP2 /etc/openvpn/client-tcp-2069.ovpn;

# pada tulisan xxx ganti dengan alamat ip address VPS anda 
/etc/init.d/openvpn restart

# masukkan certificatenya ke dalam config client TCP 2021
echo '<ca>' >> /etc/openvpn/client-tcp-2021.ovpn
cat /etc/openvpn/ca.crt >> /etc/openvpn/client-tcp-2021.ovpn
echo '</ca>' >> /etc/openvpn/client-tcp-2021.ovpn

# masukkan certificatenya ke dalam config client UDP 2021
echo '<ca>' >> /etc/openvpn/client-udp-2021.ovpn
cat /etc/openvpn/ca.crt >> /etc/openvpn/client-udp-2021.ovpn
echo '</ca>' >> /etc/openvpn/client-udp-2021.ovpn

# Copy config OpenVPN client ke home directory root agar mudah didownload ( TCP 2021 )
cp /etc/openvpn/client-tcp-2021.ovpn /home/vps/public_html/client-tcp-2021.ovpn

# Copy config OpenVPN client ke home directory root agar mudah didownload ( UDP 2021 )
cp /etc/openvpn/client-udp-2021.ovpn /home/vps/public_html/client-udp-2021.ovpn

# masukkan certificatenya ke dalam config client TCP 2069
echo '<ca>' >> /etc/openvpn/client-tcp-2069.ovpn
cat /etc/openvpn/ca.crt >> /etc/openvpn/client-tcp-2069.ovpn
echo '</ca>' >> /etc/openvpn/client-tcp-2069.ovpn

# masukkan certificatenya ke dalam config client UDP 2069
echo '<ca>' >> /etc/openvpn/client-udp-2069.ovpn
cat /etc/openvpn/ca.crt >> /etc/openvpn/client-udp-2069.ovpn
echo '</ca>' >> /etc/openvpn/client-udp-2069.ovpn

# Copy config OpenVPN client ke home directory root agar mudah didownload ( TCP 2069 )
cp /etc/openvpn/client-tcp-2069.ovpn /home/vps/public_html/client-tcp-2069.ovpn

# Copy config OpenVPN client ke home directory root agar mudah didownload ( UDP 2069 )
cp /etc/openvpn/client-udp-2069.ovpn /home/vps/public_html/client-udp-2069.ovpn


# iptables-persistent
apt install iptables-persistent -y

# firewall untuk memperbolehkan akses UDP dan akses jalur TCP

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -I POSTROUTING -s 10.5.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.6.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.7.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

iptables -A INPUT -i eth0 -m state --state NEW -p tcp --dport 3306 -j ACCEPT
iptables -A INPUT -i eth0 -m state --state NEW -p tcp --dport 7300 -j ACCEPT
iptables -A INPUT -i eth0 -m state --state NEW -p udp --dport 7300 -j ACCEPT

iptables -t nat -I POSTROUTING -s 10.5.0.0/24 -o ens3 -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.6.0.0/24 -o ens3 -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.7.0.0/24 -o ens3 -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.8.0.0/24 -o ens3 -j MASQUERADE

iptables-save > /etc/iptables/rules.v4
chmod +x /etc/iptables/rules.v4

# Reload IPTables
iptables-restore -t < /etc/iptables/rules.v4
netfilter-persistent save
netfilter-persistent reload

# Restart service openvpn
systemctl enable openvpn
systemctl start openvpn
/etc/init.d/openvpn restart

# set iptables tambahan
iptables -F -t nat
iptables -X -t nat
iptables -A POSTROUTING -t nat -j MASQUERADE
iptables-save > /etc/iptables-opvpn.conf

# Restore iptables
wget -O /etc/network/if-up.d/iptables "https://raw.githubusercontent.com/fisabiliyusri/sshsl/master/debian9/iptables-local"
chmod +x /etc/network/if-up.d/iptables

# Restore iptables rc.local
# wget -O /etc/rc.local "https://raw.githubusercontent.com/whitevps2/sshtunnel/master/debian9/iptables-openvpn"
# chmod +x /etc/rc.local

# install squid3
cd
# apt-get -y install squid3
# wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/squid3.conf"
# sed -i $MYIP2 /etc/squid/squid.conf;
# /etc/init.d/squid restart

# download script
#cd /usr/bin
#wget -O menu "https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/menu.sh"
#wget -O usernew "https://raw.githubusercontent.com/fisabiliyusri/sshsl/master/debian9/usernew.sh"
#wget -O trial "https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/trial.sh"
#wget -O hapus "https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/hapus.sh"
#wget -O cek "https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/user-login.sh"
#wget -O member "https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/user-list.sh"
#wget -O jurus69 "https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/restart.sh"
#wget -O speedtest "https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/speedtest_cli.py"
#wget -O info "https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/info.sh"
#wget -O about "https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/about.sh"
#wget -O delete "https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/delete.sh"

#echo "0 0 * * * root /sbin/reboot" > /etc/cron.d/reboot

#chmod +x menu
#chmod +x usernew
#chmod +x trial
#chmod +x hapus
#chmod +x cek
#chmod +x member
#chmod +x jurus69
#chmod +x speedtest
#chmod +x info
#chmod +x about
#chmod +x delete

# restart opevpn
/etc/init.d/openvpn restart

#auto delete
wget -O /usr/local/bin/userdelexpired "https://www.dropbox.com/s/cwe64ztqk8w622u/userdelexpired?dl=1" && chmod +x /usr/local/bin/userdelexpired

# Delete script
rm -f /root/openvpn.sh

