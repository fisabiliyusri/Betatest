clear
echo "====================================================="
echo "            Auto Insstaller Tunneling"
echo "SSH- SSL - Squid - OpenVPN - Shadowsocks - UDPGW"
echo "                  Ubuntu OS"
echo "====================================================="
echo "         Created by Kavinda Banuka Athukorala"
echo "====================================================="



sleep 5

# install wget, curl and nano
apt-get update
apt-get -y upgrade
apt-get -y install wget curl
apt-get -y install nano

#membuat banner
cat > /etc/issue.net <<-END
echo -e "\e[1;31m GHOSTKBA PRIVATE SERVER \e[0m"

 echo -e "\e[1;42m ***WAKBA*** \e[0m"
         
TERMS OF SERVICE:

echo -e "\e[1;43m
-NO SHARE ACCOUNT

-NO DDOS

-NO HACKING,CRACKING AND CARDING

-NO TORRENT

-NO SPAM

-NO PLAYSTATION SITE \e[0m"

END

#set banner openssh
sed -i 's/#Banner/Banner/g' /etc/ssh/sshd_config
service ssh restart

sleep 5

#install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=80/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 143"/g' /etc/default/dropbear
sed -i 's/DROPBEAR_BANNER=""/DROPBEAR_BANNER="\/etc\/issue.net"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
service dropbear restart

echo "--------------------------------"
echo "Dropbear Installed..."
echo "--------------------------------"

sleep 5

#instalasi squid
apt-get install squid -y
mv /etc/squid/squid.conf /etc/squid/squid.conf.bak
ip=$(ifconfig | awk -F':' '/inet addr/&&!/127.0.0.1/&&!/127.0.0.2/{split($2,_," ");print _[1]}')
cat > /etc/squid/squid.conf <<-END
acl SSL_ports port 443
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 22
acl Safe_ports port 80
acl Safe_ports port 143
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
acl SSH dst $ip/32
http_access allow SSH
http_access allow manager localhost
http_access deny manager
http_access allow localhost
http_access deny all
http_port 8080
http_port 3128
coredump_dir /var/spool/squid
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320
visible_hostname globalssh.net
END

service squid restart

echo "--------------------------------"
echo "Squid Installed..."
echo "--------------------------------"
sleep 5

#install vpn
apt-get -y install openvpn easy-rsa
cat > /etc/openvpn/server-tcp.conf <<-END
port 1194
proto tcp
dev tun
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
plugin /etc/openvpn/openvpn-plugin-auth-pam.so /etc/pam.d/login
client-cert-not-required
username-as-common-name
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 1.0.0.1"
push "route-method exe"
push "route-delay 2"
keepalive 5 30
cipher AES-128-CBC
comp-lzo
persist-key
persist-tun
status server-vpn.log
verb 3
END
cat > /etc/openvpn/server-udp.conf <<-END
port 25000
proto udp
dev tun
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
plugin /etc/openvpn/openvpn-plugin-auth-pam.so /etc/pam.d/login
client-cert-not-required
username-as-common-name
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 1.0.0.1"
push "route-method exe"
push "route-delay 2"
keepalive 5 30
cipher AES-128-CBC
comp-lzo
persist-key
persist-tun
status server-vpn.log
verb 3
END
cp -r /usr/share/easy-rsa/ /etc/openvpn
mkdir /etc/openvpn/easy-rsa/keys
wget -O /etc/openvpn/easy-rsa/vars "https://github.com/malikshi/elora/raw/master/vars"
openssl dhparam -out /etc/openvpn/dh2048.pem 2048
cd /etc/openvpn/easy-rsa
. ./vars
./clean-all
# Buat Sertifikat
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --initca $*
# buat key server
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --server server
# seting KEY CN
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" client
#copy to openvpn folder
cp /etc/openvpn/easy-rsa/keys/{server.crt,server.key,ca.crt} /etc/openvpn
ls /etc/openvpn
sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn
service openvpn restart
ip=$(ifconfig | awk -F':' '/inet addr/&&!/127.0.0.1/&&!/127.0.0.2/{split($2,_," ");print _[1]}')
cat > /etc/openvpn/globalssh.ovpn <<-END
# OpenVPN Configuration GlobalSSH Server
# Official VIP Member
client
dev tun
proto tcp
#for tcp 1194
remote $ip 1194
#for tcp + ssl/tls 1195
#remote $ip 1195
#change port and proto as you want            # rubah port dan proto sesuai yang diinginkan
#there the prosedur edit type connection      #berikut prosedur mengubah jenis koneki tcp/udp
#proto udp #with port active udp 25 & 110 choose as u want  # ganti proto tcp ke proto udp jika memakai koneksi udp
#change 1194 to 25 or 110 as the port udp u want to use     #ganti port pada remote ke port udp/tcp yang diinginkan
resolv-retry infinite
route-method exe
resolv-retry infinite
cipher AES-128-CBC
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END
echo '<ca>' >> /etc/openvpn/globalssh.ovpn
cat /etc/openvpn/ca.crt >> /etc/openvpn/globalssh.ovpn
echo '</ca>' >> /etc/openvpn/globalssh.ovpn
sed -i $ip /etc/openvpn/globalssh.ovpn
cp /usr/lib/openvpn/openvpn-plugin-auth-pam.so /etc/openvpn/

#set iptables openvz
#iptables -t nat -I POSTROUTING -s 10.8.0.0/24 -o venet0 -j MASQUERADE
#set iptables kvm
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

#allow forwarding
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

service openvpn restart
echo "--------------------------------"
echo "OpenVPN Installed..."
echo "--------------------------------"
sleep 5

# Update system repositories
apt update && apt upgrade -yuf
apt install -y --no-install-recommends gettext build-essential autoconf libtool libpcre3-dev \
                                       asciidoc xmlto libev-dev libudns-dev automake libmbedtls-dev \
                                       libsodium-dev git python-m2crypto libc-ares-dev
# download the Shadowsocks Git module
cd /opt
git clone https://github.com/shadowsocks/shadowsocks-libev.git
cd shadowsocks-libev
git submodule update --init --recursive
# Install Shadowsocks-libev
./autogen.sh
./configure
make && make install
# Create a new system user for Shadowsocks
adduser --system --no-create-home --group shadowsocks
# Create a new directory for the configuration file
mkdir -m 755 /etc/shadowsocks
# Create the Shadowsocks config
cat >> /etc/shadowsocks/shadowsocks.json <<-END
{
    "server":"$ip",
    "server_port":8388,
    "password":"globalssh",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": true
}
END
# Optimize Shadowsocks
cat >> /etc/sysctl.d/local.conf <<-END
# max open files
fs.file-max = 51200
# max read buffer
net.core.rmem_max = 67108864
# max write buffer
net.core.wmem_max = 67108864
# default read buffer
net.core.rmem_default = 65536
# default write buffer
net.core.wmem_default = 65536
# max processor input queue
net.core.netdev_max_backlog = 4096
# max backlog
net.core.somaxconn = 4096
# resist SYN flood attacks
net.ipv4.tcp_syncookies = 1
# reuse timewait sockets when safe
net.ipv4.tcp_tw_reuse = 1
# turn off fast timewait sockets recycling
net.ipv4.tcp_tw_recycle = 0
# short FIN timeout
net.ipv4.tcp_fin_timeout = 30
# short keepalive time
net.ipv4.tcp_keepalive_time = 1200
# outbound port range
net.ipv4.ip_local_port_range = 10000 65000
# max SYN backlog
net.ipv4.tcp_max_syn_backlog = 4096
# max timewait sockets held by system simultaneously
net.ipv4.tcp_max_tw_buckets = 5000
# turn on TCP Fast Open on both client and server side
net.ipv4.tcp_fastopen = 3
# TCP receive buffer
net.ipv4.tcp_rmem = 4096 87380 67108864
# TCP write buffer
net.ipv4.tcp_wmem = 4096 65536 67108864
# turn on path MTU discovery
net.ipv4.tcp_mtu_probing = 1
# for high-latency network
net.ipv4.tcp_congestion_control = hybla
# for low-latency network, use cubic instead
net.ipv4.tcp_congestion_control = cubic
END
# Apply optimizations
sysctl --system
# Create a Shadowsocks Systemd Service
cat >> /etc/systemd/system/shadowsocks.service <<-END
[Unit]
Description=Shadowsocks proxy server
[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/ss-server -c /etc/shadowsocks/shadowsocks.json -a shadowsocks -v start
ExecStop=/usr/local/bin/ss-server -c /etc/shadowsocks/shadowsocks.json -a shadowsocks -v stop
[Install]
WantedBy=multi-user.target
END
# Enable and start
systemctl daemon-reload
systemctl enable shadowsocks
systemctl start shadowsocks

echo "--------------------------------"
echo "Shadowsocks Installed..."
echo "--------------------------------"
sleep 5

#install webmin
#cat >> /etc/apt/sources.list <<-END
#deb http://download.webmin.com/download/repository sarge contrib
#deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib
#END

#wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -
#apt-get update
#apt-get -y install webmin

#echo "--------------------------------"
#echo "Webmin Installed..."
#echo "--------------------------------"
#sleep 5

#informasi SSL
country=ID
state=JawaTengah
locality=Purwokerto
organization=GlobalSSH
organizationalunit=Provider
commanname=globalssh.net
email=ceo@globalssh.net

#update repository
apt-get install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
pid = /var/run/stunnel4.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
[squid]
accept = 8000
connect = $ip:8080
[dropbear]
accept = 443
connect = $ip:143
[openssh]
accept = 444
connect = $ip:22
[openvpn]
accept = 1195
connect = $ip:1194
[shadowsocks]
accept = 8399
connect = $ip:8388
END

#membuat sertifikat
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

#konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart

echo "--------------------------------"
echo "Stunnel Installed..."
echo "--------------------------------"
sleep 5

#informasi
clear
echo "---------- Informasi --------"
echo "Installer Stunnel4 Berhasil"
echo "-----------------------------"
echo "OpenSSH             : 22"
echo "OpenSSH + SSL     : 444"
echo "Dropbear          : 80 / 143"
echo "Dropbear + SSL    : 443"
echo "Squid               : 3128 / 8000"
echo "Squid     + SSL     : 8080"
echo "OpenVPN           : 1194"
echo "OpenVPN + SSL     : 1195"
echo "Shadowsocks       : 8388"
echo "Shadowsocks + SSL : 8399"
echo "webmin            : https://$ip:10000"
echo "-----------------------------"