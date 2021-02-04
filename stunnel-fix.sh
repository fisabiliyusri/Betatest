#!/bin/bash
#created : 

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
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

# konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
cd
/etc/init.d/stunnel4 restart

#instal sslh
cd
apt-get -y install sslh

#configurasi sslh
wget -O /etc/default/sslh "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/sslh-conf"
service sslh restart
/etc/init.d/stunnel4 restart
/etc/init.d/sslh restart
