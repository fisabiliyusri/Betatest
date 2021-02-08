#!/bin/bash
# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";
# OpenVPN Ports
OpenVPN_TCP_Port='56969'
OpenVPN_UDP_Port='1945'

# Squid Ports
Squid_Port1='8080'
Squid_Port2='3128'
Squid_Port3='60000'

# OpenVPN Config Download Port
OvpnDownload_Port='85' # Before changing this value, please read this document. It contains all unsafe ports for Google Chrome Browser, please read from line #23 to line #89: https://chromium.googlesource.com/chromium/src.git/+/refs/heads/master/net/base/port_util.cc


# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

apt-get update -y
apt-get upgrade -y
# Removing some firewall tools that may affect other services
apt-get remove --purge ufw firewalld -y

# Installing some important machine essentials
apt-get install nano wget curl zip unzip tar gzip p7zip-full bc rc openssl cron net-tools dnsutils dos2unix screen bzip2 ccrypt -y

# Now installing all our wanted services
apt-get install dropbear stunnel4 ca-certificates nginx ruby apt-transport-https lsb-release squid -y

# Installing all required packages to install Webmin
apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python dbus libxml-parser-perl -y
apt-get install shared-mime-info jq fail2ban -y

# Installing a text colorizer
gem install lolcat

# Trying to remove obsolette packages after installation
apt-get autoremove -y

# Installing OpenVPN by pulling its repository inside sources.list file
rm -rf /etc/apt/sources.list.d/openvpn*
echo "deb http://build.openvpn.net/debian/openvpn/stable $(lsb_release -sc) main" > /etc/apt/sources.list.d/openvpn.list
wget -qO - http://build.openvpn.net/debian/openvpn/stable/pubkey.gpg|apt-key add -
apt-get update
apt-get install openvpn -y

# Download the webmin .deb package
# You may change its webmin version depends on the link you've loaded in this variable(.deb file only, do not load .zip or .tar.gz file):
 
WebminFile='https://github.com/johndesu090/AutoScriptDB/raw/master/Files/Plugins/webmin_1.920_all.deb'
wget -qO webmin.deb "$WebminFile"
Installing .deb package for webmin
dpkg --install webmin.deb
rm -rf webmin.deb
# Configuring webmin server config to use only http instead of https
sed -i 's|ssl=1|ssl=0|g' /etc/webmin/miniserv.conf

# Then restart to take effect
systemctl restart webmin


mkdir -p /etc/openvpn
# Removing all existing openvpn server files
rm -rf /etc/openvpn/*
# Creating server.conf, ca.crt, server.crt and server.key
cat <<'myOpenVPNconf' > /etc/openvpn/server_tcp.conf
# OpenVPN TCP
port OVPNTCP
proto tcp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh2048.pem
verify-client-cert none
username-as-common-name
key-direction 0
plugin /etc/openvpn/plugins/openvpn-plugin-auth-pam.so login
server 10.200.0.0 255.255.0.0
ifconfig-pool-persist ipp.txt
push "route-method exe"
push "route-delay 2"
keepalive 10 120
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
log tcp.log
verb 2
ncp-disable
cipher none
auth none
management 127.0.0.1 5555
myOpenVPNconf

cat <<'myOpenVPNconf2' > /etc/openvpn/server_udp.conf
# OpenVPN UDP
port OVPNUDP
proto udp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh2048.pem
verify-client-cert none
username-as-common-name
key-direction 0
plugin /etc/openvpn/plugins/openvpn-plugin-auth-pam.so login
server 10.201.0.0 255.255.0.0
ifconfig-pool-persist ipp.txt
push "route-method exe"
push "route-delay 2"
keepalive 10 120
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
log udp.log
verb 2
ncp-disable
cipher none
auth none
management 127.0.0.1 5556
myOpenVPNconf2

# install openvpn
apt-get -y install openvpn easy-rsa openssl
cp -r /usr/share/easy-rsa/ /etc/openvpn
mkdir /etc/openvpn/easy-rsa/keys
sed -i 's|export KEY_COUNTRY="US"|export KEY_COUNTRY="ID"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_PROVINCE="CA"|export KEY_PROVINCE="NUSANTARA"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_CITY="SanFrancisco"|export KEY_CITY="JAKARTA"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_ORG="Fort-Funston"|export KEY_ORG="SLSSH"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_EMAIL="me@myhost.mydomain"|export KEY_EMAIL="sulaiman.xl@facebook.com"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_OU="MyOrganizationalUnit"|export KEY_OU="www.hbogo.eu"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_NAME="EasyRSA"|export KEY_NAME="www.hbogo.eu"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_OU=changeme|export KEY_OU="www.hbogo.eu" |' /etc/openvpn/easy-rsa/vars

# Create Diffie-Helman Pem
openssl dhparam -out /etc/openvpn/dh2048.pem 2048

# Create PKI
cd /etc/openvpn/easy-rsa
cp openssl-1.0.0.cnf openssl.cnf
. ./vars
./clean-all
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --initca $*

# Create key server
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --server server

# Setting KEY CN
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" client

# cp /etc/openvpn/easy-rsa/keys/{server.crt,server.key,ca.crt} /etc/openvpn
cd
cp /etc/openvpn/easy-rsa/keys/server.crt /etc/openvpn/server.crt
cp /etc/openvpn/easy-rsa/keys/server.key /etc/openvpn/server.key
cp /etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn/ca.crt
chmod +x /etc/openvpn/ca.crt

 # Getting all dns inside resolv.conf then use as Default DNS for our openvpn server
 grep -v '#' /etc/resolv.conf | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read -r line; do
	echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server_tcp.conf
done

 # Creating a New update message in server.conf
cat <<'NUovpn' > /etc/openvpn/server.conf

 # New Update are now released, OpenVPN Server
 # are now running both TCP and UDP Protocol. (Both are only running on IPv4)
 # But our native server.conf are now removed and divided
 # Into two different configs base on their Protocols:
 #  * OpenVPN TCP (located at /etc/openvpn/server_tcp.conf
 #  * OpenVPN UDP (located at /etc/openvpn/server_udp.conf
 # 
 # Also other logging files like
 # status logs and server logs
 # are moved into new different file names:
 #  * OpenVPN TCP Server logs (/etc/openvpn/tcp.log)
 #  * OpenVPN UDP Server logs (/etc/openvpn/udp.log)
 #  * OpenVPN TCP Status logs (/etc/openvpn/tcp_stats.log)
 #  * OpenVPN UDP Status logs (/etc/openvpn/udp_stats.log)
 #
 # Server ports are configured base on env vars
 # executed/raised from this script (OpenVPN_TCP_Port/OpenVPN_UDP_Port)
 #
 # Enjoy the new update
 # Script Updated by SL
NUovpn

 # setting openvpn server port
sed -i "s|OVPNTCP|$OpenVPN_TCP_Port|g" /etc/openvpn/server_tcp.conf
sed -i "s|OVPNUDP|$OpenVPN_UDP_Port|g" /etc/openvpn/server_udp.conf
 
 
# Getting some OpenVPN plugins for unix authentication
cd
wget https://github.com/johndesu090/AutoScriptDB/raw/master/Files/Plugins/plugin.tgz
tar -xzvf /root/plugin.tgz -C /etc/openvpn/
rm -f plugin.tgz
#
systemctl start openvpn@server_tcp
systemctl enable openvpn@server_tcp
systemctl start openvpn@server_udp
systemctl enable openvpn@server_udp
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -t nat -I POSTROUTING -s 10.200.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.201.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -I POSTROUTING -s 192.168.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/iptables.up.rules
wget -O /etc/network/if-up.d/iptables "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/iptables"
chmod +x /etc/network/if-up.d/iptables
sed -i 's|LimitNPROC|#LimitNPROC|g' /lib/systemd/system/openvpn@.service
systemctl daemon-reload
/etc/init.d/openvpn restart

# Removing Duplicate Squid config
rm -rf /etc/squid/squid.con*

# Creating Squid server config using cat eof tricks
cat <<'mySquid' > /etc/squid/squid.conf
# My Squid Proxy Server Config
acl localhost src 127.0.0.1/32 ::1
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 ::1
acl VPN dst xxxxxxxxx/32
acl SSH dst xxxxxxxxx/32
# Izinkan Port SSL
acl SSL_ports port 1-62100
acl SSL_ports port 443
acl SSL_ports port 222
acl SSL_ports port 43
acl SSL_ports port 69
acl SSL_ports port 600
acl SSL_ports port 700
acl SSL_ports port 800
acl SSL_ports port 900
acl SSL_ports port 444
acl SSL_ports port 777
acl SSL_ports port 540
acl SSL_ports port 551
acl SSL_ports port 9900
acl SSL_ports port 569
acl SSL_ports port 8181
acl SSL_ports port 3129
# Izinkan port ssh vpn
acl Safe_ports port 1-62100
acl Safe_ports port 569
acl Safe_ports port 1945
acl Safe_ports port 22
acl Safe_ports port 143
acl Safe_ports port 200
acl Safe_ports port 400
acl Safe_ports port 8000
acl Safe_ports port 1078
acl Safe_ports port 450
acl Safe_ports port 77
acl Safe_ports port 550
acl Safe_ports port 9000
acl Safe_ports port 80
acl CONNECT method CONNECT
http_access allow VPN
http_access allow SSH
http_access allow localhost
http_access deny all 
http_port 0.0.0.0:Squid_Port1
http_port 0.0.0.0:Squid_Port2
http_port 0.0.0.0:Squid_Port3
### Allow Headers
request_header_access Allow allow all 
request_header_access Authorization allow all 
request_header_access WWW-Authenticate allow all 
request_header_access Proxy-Authorization allow all 
request_header_access Proxy-Authenticate allow all 
request_header_access Cache-Control allow all 
request_header_access Content-Encoding allow all 
request_header_access Content-Length allow all 
request_header_access Content-Type allow all 
request_header_access Date allow all 
request_header_access Expires allow all 
request_header_access Host allow all 
request_header_access If-Modified-Since allow all 
request_header_access Last-Modified allow all 
request_header_access Location allow all 
request_header_access Pragma allow all 
request_header_access Accept allow all 
request_header_access Accept-Charset allow all 
request_header_access Accept-Encoding allow all 
request_header_access Accept-Language allow all 
request_header_access Content-Language allow all 
request_header_access Mime-Version allow all 
request_header_access Retry-After allow all 
request_header_access Title allow all 
request_header_access Connection allow all 
request_header_access Proxy-Connection allow all 
request_header_access User-Agent allow all 
request_header_access Cookie allow all 
request_header_access All deny all
### HTTP Anonymizer Paranoid
reply_header_access Allow allow all 
reply_header_access Authorization allow all 
reply_header_access WWW-Authenticate allow all 
reply_header_access Proxy-Authorization allow all 
reply_header_access Proxy-Authenticate allow all 
reply_header_access Cache-Control allow all 
reply_header_access Content-Encoding allow all 
reply_header_access Content-Length allow all 
reply_header_access Content-Type allow all 
reply_header_access Date allow all 
reply_header_access Expires allow all 
reply_header_access Host allow all 
reply_header_access If-Modified-Since allow all 
reply_header_access Last-Modified allow all 
reply_header_access Location allow all 
reply_header_access Pragma allow all 
reply_header_access Accept allow all 
reply_header_access Accept-Charset allow all 
reply_header_access Accept-Encoding allow all 
reply_header_access Accept-Language allow all 
reply_header_access Content-Language allow all 
reply_header_access Mime-Version allow all 
reply_header_access Retry-After allow all 
reply_header_access Title allow all 
reply_header_access Connection allow all 
reply_header_access Proxy-Connection allow all 
reply_header_access User-Agent allow all 
reply_header_access Cookie allow all 
reply_header_access All deny all
### CoreDump
coredump_dir /var/spool/squid
dns_nameservers 8.8.8.8 8.8.4.4
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
visible_hostname SulaimanL
mySquid

# setting
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s|xxxxxxxxx|$MYIP|g";
sed -i "s|xxxxxxxxx|$MYIP|g" /etc/squid/squid.conf

# Setting machine's IP Address inside of our Squid config(security that only allows this machine to use this proxy server)
sed -i "s|IP-ADDRESS|$IPADDR|g" /etc/squid/squid.conf
# Setting squid ports
sed -i "s|Squid_Port1|$Squid_Port1|g" /etc/squid/squid.conf
sed -i "s|Squid_Port2|$Squid_Port2|g" /etc/squid/squid.conf
sed -i "s|Squid_Port3|$Squid_Port3|g" /etc/squid/squid.conf

# Starting Proxy server
echo -e "Restarting proxy server..."
systemctl restart squid

# Creating nginx config for our ovpn config downloads webserver
cat <<'myNginxC' > /etc/nginx/conf.d/sl-ovpn-config.conf
# My OpenVPN Config Download Directory
server {
 listen 0.0.0.0:myNginx;
 server_name localhost;
 root /var/www/openvpn;
 index index.html;
}
myNginxC

# Setting our nginx config port for .ovpn download site
sed -i "s|myNginx|$OvpnDownload_Port|g" /etc/nginx/conf.d/sl-ovpn-config.conf

# Removing Default nginx page(port 80)
rm -rf /etc/nginx/sites-*

# Creating our root directory for all of our .ovpn configs
rm -rf /var/www/openvpn
mkdir -p /var/www/openvpn

#  Buat Config OpenVPN 

cat <<EOF16> /var/www/openvpn/line.me-tcp.ovpn
# SulaimanL VPN Premium Script
# SL OpenVPN Service TCP
# Kuota Line /Unliapps/Unlimax
client
dev tun
proto tcp
setenv FRIENDLY_NAME "SL VPN Kuota Lineme"
remote $MYIP $OpenVPN_TCP_Port
remote-cert-tls server
connect-retry infinite
resolv-retry infinite
nobind
persist-key
persist-tun
auth-user-pass
auth none
auth-nocache
cipher none
comp-lzo
redirect-gateway def1
setenv CLIENT_CERT 0
reneg-sec 0
verb 1
http-proxy $MYIP $Squid_Port1
http-proxy-option CUSTOM-HEADER Host line.me
http-proxy-option CUSTOM-HEADER X-Online-Host line.me
http-proxy-option CUSTOM-HEADER X-Forwarded-For line.me

<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
EOF16

cat <<EOF162> /var/www/openvpn/sl-udp.ovpn
# SulaimanL VPN Premium Script
# SL OpenVPN Service UDP
client
dev tun
proto udp
setenv FRIENDLY_NAME "SL VPN UDP"
remote $MYIP $OpenVPN_UDP_Port
remote-cert-tls server
resolv-retry infinite
float
fast-io
nobind
persist-key
persist-remote-ip
persist-tun
auth-user-pass
auth none
auth-nocache
cipher none
comp-lzo
redirect-gateway def1
setenv CLIENT_CERT 0
reneg-sec 0
verb 1

<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
EOF162

cat <<EOF17> /var/www/openvpn/tcp.ovpn
# SulaimanL VPN Premium Script
# SL OpenVPN Service TCP
client
dev tun
proto tcp-client
setenv FRIENDLY_NAME "SL VPN TCP"
remote $MYIP $OpenVPN_TCP_Port
remote-cert-tls server
bind
float
mute-replay-warnings
connect-retry-max 9999
redirect-gateway def1
connect-retry 0 1
resolv-retry infinite
setenv CLIENT_CERT 0
persist-tun
persist-key
auth-user-pass
auth none
auth-nocache
auth-retry interact
cipher none
comp-lzo
reneg-sec 0
verb 0
nice -20
<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
EOF17

cat <<EOF152> /var/www/openvpn/whatsapp.ovpn
# SulaimanL VPN Premium Script
# SL OpenVPN Service TCP
# Kuota Whatsapp Telkomsel
client
dev tun
proto tcp-client
setenv FRIENDLY_NAME "SL VPN Kouta Whatsapp"
remote $MYIP $OpenVPN_TCP_Port
nobind
persist-key
persist-tun
comp-lzo
keepalive 10 120
tls-client
remote-cert-tls server
verb 2
auth-user-pass
cipher none
auth none
auth-nocache
auth-retry interact
connect-retry 0 1
nice -20
reneg-sec 0
redirect-gateway def1
setenv CLIENT_CERT 0
dhcp-option DNS 1.1.1.1
dhcp-option DNS 1.0.0.1
http-proxy $MYIP $Squid_Port1
http-proxy-option VERSION 1.1
http-proxy-option CUSTOM-HEADER Host www.whatsapp.net.whatsapp.com
http-proxy-option CUSTOM-HEADER X-Forwarded-For www.whatsapp.net.whatsapp.com

<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
EOF152

cat <<EOF1152> /var/www/openvpn/youtube.ovpn
# SulaimanL VPN Premium Script
# SL OpenVPN Service TCP
# Kuota Youtube Telkomsel
client
dev tun
proto tcp-client
setenv FRIENDLY_NAME "SL Youtube Tsel"
remote $MYIP $OpenVPN_TCP_Port
nobind
persist-key
persist-tun
comp-lzo
keepalive 10 120
tls-client
remote-cert-tls server
verb 3
auth-user-pass
cipher none
auth none
auth-nocache
auth-retry interact
connect-retry 0 1
nice -20
reneg-sec 0
redirect-gateway def1
setenv CLIENT_CERT 0
dhcp-option DNS 1.1.1.1
dhcp-option DNS 1.0.0.1
http-proxy $MYIP $Squid_Port1
http-proxy-option CUSTOM-HEADER CONNECT HTTP/1.0
http-proxy-option CUSTOM-HEADER Host www.googlevideo.com
http-proxy-option CUSTOM-HEADER X-Online-Host www.googlevideo.com
http-proxy-option CUSTOM-HEADER X-Forward-Host www.googlevideo.com
http-proxy-option CUSTOM-HEADER Connection Keep-Alive

<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
EOF1152

cat <<EOF1632> /var/www/openvpn/beta.ovpn
# Sulaiman VPN Premium Script
# SL OpenVPN Service
client
dev tun
proto tcp-client
setenv FRIENDLY_NAME "SL VPN Beta Test"
remote $MYIP $OpenVPN_TCP_Port
nobind
persist-key
persist-tun
comp-lzo
keepalive 10 120
tls-client
remote-cert-tls server
verb 2
auth-user-pass
cipher none
auth none
auth-nocache
auth-retry interact
connect-retry 0 1
nice -20
reneg-sec 0
redirect-gateway def1
setenv CLIENT_CERT 0
dhcp-option DNS 1.1.1.1
dhcp-option DNS 1.0.0.1
http-proxy $MYIP $Squid_Port1
http-proxy-option CUSTOM-HEADER CONNECT HTTP/1.0
http-proxy-option CUSTOM-HEADER Host sl.whatsapp.com.spotify.com.line-apps.com
http-proxy-option CUSTOM-HEADER X-Online-Host sl.whatsapp.com.spotify.com.line-apps.com
http-proxy-option CUSTOM-HEADER X-Forward-Host sl.whatsapp.com.spotify.com.line-apps.com
http-proxy-option CUSTOM-HEADER Connection Keep-Alive

<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
EOF1632

# hapus
rm -rf /etc/nginx/conf.d/vps.conf

# Creating OVPN download site index.html
cat <<'mySiteOvpn' > /var/www/openvpn/index.html
<!DOCTYPE html>
<html lang="en">

<!-- Simple OVPN Download site by SulaimanL -->

<head><meta charset="utf-8" /><title>SulaimanL OVPN Config Download</title><meta name="description" content="MyScriptName Server" /><meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" name="viewport" /><meta name="theme-color" content="#000000" /><link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.2/css/all.css"><link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.3.1/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdnjs.cloudflare.com/ajax/libs/mdbootstrap/4.8.3/css/mdb.min.css" rel="stylesheet"></head><body><div class="container justify-content-center" style="margin-top:9em;margin-bottom:5em;"><div class="col-md"><div class="view"><img src="https://openvpn.net/wp-content/uploads/openvpn.jpg" class="card-img-top"><div class="mask rgba-white-slight"></div></div><div class="card"><div class="card-body"><h5 class="card-title">Config List</h5><br /><ul class="list-group"><li class="list-group-item justify-content-between align-items-center" style="margin-bottom:1em;"><p>Mod By SL <span class="badge light-blue darken-4">Android/iOS/PC/Modem</span><br /><small> UDP TCL SSL</small></p><a class="btn btn-outline-success waves-effect btn-sm" href="http://IP-ADDRESS:NGINXPORT/configs.zip" style="float:right;"><i class="fa fa-download"></i> Download</a></li><li class="list-group-item justify-content-between align-items-center" style="margin-bottom:1em;"><p>For Sun <span class="badge light-blue darken-4">Android/iOS/PC/Modem</span><br /><small> TCP+Proxy Server UDP</small></p><a class="btn btn-outline-success waves-effect btn-sm" href="http://IP-ADDRESS:NGINXPORT/configs.zip" style="float:right;"><i class="fa fa-download"></i> Download</a></li><li class="list-group-item justify-content-between align-items-center" style="margin-bottom:1em;"><p>For SL <span class="badge light-blue darken-4">Android/iOS/PC/Modem</span><br /><small> config openvpn</small></p><a class="btn btn-outline-success waves-effect btn-sm" href="http://IP-ADDRESS:NGINXPORT/configs.zip" style="float:right;"><i class="fa fa-download"></i> Download</a></li><li class="list-group-item justify-content-between align-items-center" style="margin-bottom:1em;"><p>For Sun <span class="badge light-blue darken-4">Modem</span><br /><small> config openvpn</small></p><a class="btn btn-outline-success waves-effect btn-sm" href="http://IP-ADDRESS:NGINXPORT/configs.zip" style="float:right;"><i class="fa fa-download"></i> Download</a></li></ul></div></div></div></div></body></html>
mySiteOvpn
 
 # Setting template's correct name,IP address and nginx Port
sed -i "s|NGINXPORT|$OvpnDownload_Port|g" /var/www/openvpn/index.html
sed -i "s|xxxxxxxxx|$MYIP|g" /var/www/openvpn/index.html

# Restarting nginx service
systemctl restart nginx
 
 # Creating all .ovpn config archives
# Kuota Maxstream Tsel
cd /var/www/openvpn
wget https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/SL-Maxstream.ehi
# Kuota Whatsapp/Kemdikbud Tsel
cd /var/www/openvpn
wget https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/SL-Wa-Kemdikbud.ehi
# Kuota Youtube Tsel
cd /var/www/openvpn
wget https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/SL-YoutubeTsel.ehi
# zip
cd
cd /var/www/openvpn
zip -qq -r configs.zip *.ovpn *.ehi
cd
apt-get -y update --fix-missing

echo " "
echo "Application & Port Information"  | tee -a log-install.txt
echo "   - OpenVPN		: TCP $OpenVPN_TCP_Port UDP $OpenVPN_UDP_Port "  | tee -a log-install.txt
echo "   - Squid Proxy	: $Squid_Port1 , $Squid_Port2 (limit to IP Server)"  | tee -a log-install.txt
echo "   - Squid ELITE	: $Squid_Port3 (limit to IP Server)"  | tee -a log-install.txt
echo "   - Webmin                  : http://$MYIP:10000/"  | tee -a log-install.txt
echo "OpenVPN Configs Download"  | tee -a log-install.txt
echo "   - OpenVPN Link           : http://$MYIP:85/configs.zip"  | tee -a log-install.txt
echo " SulaimanL"  | tee -a log-install.txt
echo " Facebook: https://fb.me/sulaiman.xl"  | tee -a log-install.txt
echo " Please Reboot your VPS"

# Clearing all logs from installation
rm -rf /root/.bash_history && history -c && echo '' > /var/log/syslog

}
function ip_address(){
  local IP="$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )"
  [ -z "${IP}" ] && IP="$( wget -qO- -t1 -T2 ipv4.icanhazip.com )"
  [ -z "${IP}" ] && IP="$( wget -qO- -t1 -T2 ipinfo.io/ip )"
  [ ! -z "${IP}" ] && echo "${IP}" || echo
} 

