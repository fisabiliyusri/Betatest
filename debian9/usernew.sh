# !/bin/bash
# Script auto create user SSH

read -p "Username : " Login
read -p "Password : " Pass
read -p "Expired (hari): " masaaktif

IP=`curl ipv4.icanhazip.com`
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e ""
echo -e "==========================="
echo -e "====Informasi SSH Account==" 
echo -e "==== Premium Akun SSH =====" 
echo -e "Host SSH : #$IP" 
echo -e "Port SSH" 
echo -e "OpenSSH : 143,200,400,1078,8000" 
echo -e "Dropbear : 44,77,450,550,9000" 
echo -e "SSL/TLS SSH : 443" 
echo -e "SSL/TLS OpenSSH : 43,600,700,800,900" 
echo -e "SSL/TLS Dropbear : 444,540,551,777,9900" 
echo -e "Port Proxy Squid "
echo -e "Proxy Squid : 8080,3128"
echo -e "Proxy Squid SSL : 8181,3129"
echo -e "BadVPN-UDPGW : 7100,7200,7300"
echo -e "Speed Server : 2 Gbps" 
echo -e "Transfer : 2 TB" 
echo -e "Username : $Login " 
echo -e "Password : $Pass" 
echo -e "---------------------------" 
echo -e "Aktif Sampai      : $exp" 
echo -e "==========================="
echo -e " Link Download"
echo -e "Config OpenVPN dan HTTP Injector "
echo -e "http://#$IP:85/configs.zip" 
echo -e "http://#$IP:85/index.html" 
echo -e "Hapus Tanda #"
echo -e "OpenVPN TLS/SSL : 569"
echo -e "OpenVPN TCP : 56969"
echo -e "OpenVPN UDP : 1945"
echo -e "==========================="
echo -e "Mod by Sulaiman L"  
echo -e ""
