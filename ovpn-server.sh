#!/bin/bash
#created : 

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";

# detail nama perusahaan
country=ID
state=SeluruhIndonesia
locality=JawaSumateraKalimantanPapua
organization=SLSSH
commonname=www.hbogo.eu
email=sulaiman.xl@facebook.com

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

# server settings
cd /etc/openvpn/
wget -O /etc/openvpn/server.tcp.conf "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/server-tcp.conf"
wget -O /etc/openvpn/server.udp.conf "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/server-udp.conf"
systemctl start openvpn@server.tcp
systemctl start openvpn@server.udp
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -t nat -I POSTROUTING -s 10.7.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.5.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -I POSTROUTING -s 192.168.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/iptables.up.rules
wget -O /etc/network/if-up.d/iptables "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/iptables"
chmod +x /etc/network/if-up.d/iptables
sed -i 's|LimitNPROC|#LimitNPROC|g' /lib/systemd/system/openvpn@.service
systemctl daemon-reload
/etc/init.d/openvpn restart
