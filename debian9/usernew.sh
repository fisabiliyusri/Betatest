# !/bin/bash
# openvpn config
# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";
# hapus
rm -rf /etc/openvpn/client-udp.ovpn
rm -rf /etc/openvpn/client-tcp.ovpn
rm -rf /etc/openvpn/569client-ssl.ovpn
rm -rf /home/vps/public_html/client-udp.ovpn
rm -rf /home/vps/public_html/client-tcp.ovpn
rm -rf /home/vps/public_html/569client-ssl.ovpn

# buat udp
cd /etc/openvpn/
wget -O /etc/openvpn/client-udp.ovpn "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/client-udp.conf"
sed -i $MYIP2 /etc/openvpn/client-udp.ovpn;
echo '<ca>' >> /etc/openvpn/client-udp.ovpn
cat /etc/openvpn/ca.crt >> /etc/openvpn/client-udp.ovpn
echo '</ca>' >> /etc/openvpn/client-udp.ovpn
cp /etc/openvpn/client-udp.ovpn /home/vps/public_html

#buat tcp
wget -O /etc/openvpn/client-tcp.ovpn "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/debian9/client-tcp.conf"
sed -i $MYIP2 /etc/openvpn/client-tcp.ovpn;
echo '<ca>' >> /etc/openvpn/client-tcp.ovpn
cat /etc/openvpn/ca.crt >> /etc/openvpn/client-tcp.ovpn
echo '</ca>' >> /etc/openvpn/client-tcp.ovpn
cp /etc/openvpn/client-tcp.ovpn /home/vps/public_html/

#buat ssl
wget -O /etc/openvpn/569client-ssl.ovpn "https://raw.githubusercontent.com/fisabiliyusri/Betatest/master/569client-ssl.conf"
sed -i $MYIP2 /etc/openvpn/569client-ssl.ovpn;
echo '<ca>' >> /etc/openvpn/569client-ssl.ovpn
cat /etc/openvpn/ca.crt >> /etc/openvpn/569client-ssl.ovpn
echo '</ca>' >> /etc/openvpn/569client-ssl.ovpn
cp /etc/openvpn/569client-ssl.ovpn /home/vps/public_html/


# Script auto create user SSH

read -p "Username : " Login
read -p "Password : " Pass
read -p "Expired (hari): " masaaktif

IP=`curl ipv4.icanhazip.com`
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e ""
echo -e "====Informasi SSH Account====" 
echo -e "=====  Premium Akun SSH =====" 
echo -e "Host : $IP" 
echo -e "Port SSH" 
echo -e "OpenSSH : 143,200,400,1078,8000" 
echo -e "Dropbear : 44,77,450,550,9000" 
echo -e "SSL/TLS SSH : 443" 
echo -e "SSL/TLS OpenSSH : 43,600,700,800,900" 
echo -e "SSL/TLS Dropbear : 444,540,551,777,9900" 
echo -e "SSL/TLS SSR SSH : 69" 
echo -e "OpenVPN TLS/SSL : 569" 
echo -e "BadVPN-UDPGW : 7100,7200,7300"
echo -e "Speed Server : 2 Gbps" 
echo -e "Transfer : 2 TB" 
echo -e "Username : $Login " 
echo -e "Password : $Pass" 
echo -e "-----------------------------" 
echo -e "Aktif Sampai      : $exp" 
echo -e "============================="
echo -e "Mod by Sulaiman L" 
echo -e "=============================" 
echo -e "Config OpenVPN (TCP 56969): "
echo -e "http:// $IP :81/client-tcp.ovpn" 
echo -e "=============================" 
echo -e "Config OpenVPN (UDP 1945): "
echo -e "http:// $IP :81/client-udp.ovpn"
echo -e "=============================" 
echo -e "Config OpenVPN (TCP+SSL 569): "
echo -e "http:// $IP :81/569client-ssl.ovpn"
echo -e "=============================" 
echo -e ""
