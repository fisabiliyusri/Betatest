# !/bin/bash
# Script auto create trial user SSH
# yg akan expired setelah 1 hari
# modified by White-vps.com

IP=`curl icanhazip.com`

Login=trial`</dev/urandom tr -dc X-Z0-9 | head -c4`
hari="1"
Pass=`</dev/urandom tr -dc a-f0-9 | head -c9`

useradd -e `date -d "$hari days" +"%Y-%m-%d"` -s /bin/false -M $Login
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e ""
echo -e "=====  Trial Premium Akun SSH =====" 
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
echo -e "Masa Aktif 1 Hari"
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
echo -e "http:// $IP :81/569client-ssl.ovpn
echo -e "=============================" 
echo -e ""
