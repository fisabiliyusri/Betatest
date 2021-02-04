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

# go to root

# configure rc.local
cat <<EOF >/etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

exit 0
EOF
chmod +x /etc/rc.local
systemctl daemon-reload
systemctl start rc-local

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# add dns server ipv4
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf
sed -i '$ i\echo "nameserver 1.1.1.1" > /etc/resolv.conf' /etc/rc.local
sed -i '$ i\echo "nameserver 1.0.0.1" >> /etc/resolv.conf' /etc/rc.local

# install wget and curl
apt-get -y install wget curl

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
/etc/init.d/ssh restart

# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Ubah izin akses
chmod +x /etc/rc.local

# enable rc local
systemctl enable rc-local
systemctl start rc-local.service

# update
apt-get update -y

# install webserver
apt-get -y install nginx

# install essential package
apt-get -y install nano iptables-persistent dnsutils screen whois ngrep unzip unrar


# install webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by SLSSH</pre>" > /home/vps/public_html/index.html
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/vps.conf"

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
systemctl start openvpn@server.tcp
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

# openvpn config
wget -O /etc/openvpn/client-udp.ovpn "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/client-udp.conf"
sed -i $MYIP2 /etc/openvpn/client-udp.ovpn;
echo '<ca>' >> /etc/openvpn/client-udp.ovpn
cat /etc/openvpn/ca.crt >> /etc/openvpn/client-udp.ovpn
echo '</ca>' >> /etc/openvpn/client-udp.ovpn
cp client-udp.ovpn /home/vps/public_html/
wget -O /etc/openvpn/client-tcp.ovpn "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/client-tcp.conf"
sed -i $MYIP2 /etc/openvpn/client-tcp.ovpn;
echo '<ca>' >> /etc/openvpn/client-tcp.ovpn
cat /etc/openvpn/ca.crt >> /etc/openvpn/client-tcp.ovpn
echo '</ca>' >> /etc/openvpn/client-tcp.ovpn
cp client-tcp.ovpn /home/vps/public_html/
wget -O /etc/openvpn/569client-ssl.ovpn "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/569client-ssl.conf"
sed -i $MYIP2 /etc/openvpn/569client-ssl.ovpn;
echo '<ca>' >> /etc/openvpn/569client-ssl.ovpn
cat /etc/openvpn/ca.crt >> /etc/openvpn/569client-ssl.ovpn
echo '</ca>' >> /etc/openvpn/569client-ssl.ovpn
cp 569client-ssl.ovpn /home/vps/public_html/

echo "===  install neofetch  ==="
# install neofetch
apt-get update -y
apt-get -y install gcc
apt-get -y install make
apt-get -y install cmake
apt-get -y install git
apt-get -y install screen
apt-get -y install unzip
apt-get -y install curl
apt-get -y install ruby
gem install lolcat
apt-get -y install neofetch
cd
echo "neofetch" >> .profile

# instal php5.6 ubuntu 16.04 64bit
apt-get -y update

# setting port ssh
cd
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 1078' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 8000' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 400' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 200' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
/etc/init.d/ssh restart

echo "===  install Dropbear ==="

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=44/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 450 -p 550 -p 9000 -p 77 "/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
/etc/init.d/ssh restart
/etc/init.d/dropbear restart


# setting dan install vnstat debian 9 64bit
apt-get -y install vnstat
systemctl start vnstat
systemctl enable vnstat
chkconfig vnstat on
chown -R vnstat:vnstat /var/lib/vnstat

echo "===  install stunnel  ===="
# install stunnel
apt-get install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
[sslopenssh]
accept = 222
connect = 127.0.0.1:22
[sslopenssh]
accept = 43
connect = 127.0.0.1:143
[sshsslssr]
accept = 69
connect = 127.0.0.1:6969
[sslopenssh]
accept = 600
connect = 127.0.0.1:400
[sshopenssh]
accept = 700
connect = 127.0.0.1:200
[sshopenssh]
accept = 800
connect = 127.0.0.1:1078
[sshopenssh]
accept = 900
connect = 127.0.0.1:8000
[ssldropbear]
accept = 444
connect = 127.0.0.1:44
[ssldropbear]
accept = 777
connect = 127.0.0.1:77
[ssldropbear]
accept = 540
connect = 127.0.0.1:450
[ssldropbear]
accept = 551
connect = 127.0.0.1:550
[ssldropbear]
accept = 9900
connect = 127.0.0.1:9000
[openvpn]
accept = 569
connect = 127.0.0.1:56969
[shadowsocksssl]
accept = 7240
connect = 127.0.0.1:7230


END

echo "=================  membuat Sertifikat OpenSSL ======================"
echo "========================================================="
#membuat sertifikat
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

# konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
cd
/etc/init.d/stunnel4 restart

# common password debian 
wget -O /etc/pam.d/common-password "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/common-password-deb9"
chmod +x /etc/pam.d/common-password

#instal sslh
cd
apt-get -y install sslh

#configurasi sslh
wget -O /etc/default/sslh "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/sslh-conf"
service sslh restart

echo "=== Auto Installer BadVPN UDPGW ==="
# buat directory badvpn
cd /usr/bin
mkdir build
cd build
wget https://github.com/ambrop72/badvpn/archive/1.999.130.tar.gz
tar xvzf 1.999.130.tar.gz
cd badvpn-1.999.130
cmake -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_TUN2SOCKS=1 -DBUILD_UDPGW=1
make install
make -i install

# auto start badvpn single port
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10' /etc/rc.local
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500 --max-connections-for-client 20 &
cd

# auto start badvpn second port
#cd /usr/bin/build/badvpn-1.999.130
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 1000 --max-connections-for-client 10' /etc/rc.local
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500 --max-connections-for-client 20 &
cd

# auto start badvpn second port
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 1000 --max-connections-for-client 10' /etc/rc.local
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500 --max-connections-for-client 20 &
cd

# permition
chmod +x /usr/local/bin/badvpn-udpgw
chmod +x /usr/local/share/man/man7/badvpn.7
chmod +x /usr/local/bin/badvpn-tun2socks
chmod +x /usr/local/share/man/man8/badvpn-tun2socks.8
chmod +x /usr/bin/build
chmod +x /etc/rc.local

# Custom Banner SSH
wget -O /etc/issue.net "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/banner-custom.conf"
chmod +x /etc/issue.net

echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
echo "DROPBEAR_BANNER="/etc/issue.net"" >> /etc/default/dropbear

# install fail2ban
apt-get -y install fail2ban
service fail2ban restart

# Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'

# xml parser
cd
apt-get install -y libxml-parser-perl

# download script
cd /usr/bin
wget -O menu "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/menu.sh"
wget -O usernew "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/usernew.sh"
wget -O trial "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/trial.sh"
wget -O hapus "https://raw.githubusercontent.com/fisabiliyusri/sshsl/master/debian9/hapus.sh"
wget -O cek "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/user-login.sh"
wget -O cekconfig "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/cekconfig.sh"
wget -O member "https://raw.githubusercontent.com/fisabiliyusri/sshsl/master/debian9/user-list.sh"
wget -O crot69 "https://raw.githubusercontent.com/fisabiliyusri/sshsl/master/debian9/restart.sh"
wget -O speedtest "https://raw.githubusercontent.com/fisabiliyusri/sshsl/master/debian9/speedtest_cli.py"
wget -O info "https://raw.githubusercontent.com/fisabiliyusri/sshsl/master/debian9/info.sh"
wget -O shadowsl "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/Auto-Install-Shadowsocks-SL.sh"
wget -O monitorvpn "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/auto-install-openvpn-monitor.sh"
wget --no-check-certificate -O shadowsocks-all "https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-all.sh"
wget -O fixvpn "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/fix-vpn.sh"
wget -O install-config "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/install-config.sh"
wget -O about "https://raw.githubusercontent.com/fisabiliyusri/sshsl/master/debian9/about.sh"
wget -O delete "https://raw.githubusercontent.com/fisabiliyusri/sshsl/master/debian9/delete.sh"

echo "0 0 * * * root /sbin/reboot" > /etc/cron.d/reboot

chmod +x menu
chmod +x usernew
chmod +x trial
chmod +x hapus
chmod +x cek
chmod +x cekconfig
chmod +x member
chmod +x crot69
chmod +x speedtest
chmod +x info
chmod +x shadowsl
chmod +x monitorvpn
chmod +x shadowsocks-all
chmod +x fixvpn
chmod +x install-config
chmod +x about
chmod +x delete

# finishing
cd
chown -R www-data:www-data /home/vps/public_html
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/stunnel4 restart
#service squid restart
/etc/init.d/nginx restart
/etc/init.d/openvpn restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# 
apt-get -y update --fix-missing

# info
clear
cd

# auto Delete Acount SSH Expired
wget -O /usr/local/bin/userdelexpired "https://www.dropbox.com/s/cwe64ztqk8w622u/userdelexpired?dl=1" && chmod +x /usr/local/bin/userdelexpired

rm -f /root/openssh.sh

echo "==================== Restart Service ===================="
echo "========================================================="
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/stunnel4 restart
/etc/init.d/sslh restart
/etc/init.d/shadowsocks-r restart
/etc/init.d/nginx restart
/etc/init.d/php5.6-fpm restart
/etc/init.d/openvpn restart

# Delete script
#rm -f /root/openvpn.sh
